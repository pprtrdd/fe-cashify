import 'package:cashify/features/transaction/data/models/movement_model.dart';
import 'package:cashify/features/transaction/domain/entities/movement_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class MovementRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  MovementRepository(this._firestore, this._auth);

  String get _currentUid =>
      _auth.currentUser?.uid ?? (throw Exception("No auth"));
  DocumentReference _getPeriodDoc(String billingPeriodId) {
    return _firestore
        .collection("users")
        .doc(_currentUid)
        .collection("billing_periods")
        .doc(billingPeriodId);
  }

  String _getMovementsPath(String billingPeriodId) {
    return "users/$_currentUid/billing_periods/$billingPeriodId/movements";
  }

  Future<void> save(MovementEntity m) async {
    try {
      final periodDoc = _getPeriodDoc(m.billingPeriodId);

      await periodDoc.set({
        'id': m.billingPeriodId,
        'year': m.billingPeriodYear,
        'month': m.billingPeriodMonth,
        'lastUpdate': FieldValue.serverTimestamp(),
        'status': 'active',
      }, SetOptions(merge: true));

      await periodDoc
          .collection("movements")
          .add(MovementModel.fromEntity(m).toFirestore());
    } catch (e) {
      debugPrint("Error saving: $e");
      rethrow;
    }
  }

  Future<void> update(MovementEntity m) async {
    final path = _getMovementsPath(m.billingPeriodId);
    await _firestore
        .collection(path)
        .doc(m.id)
        .update(MovementModel.fromEntity(m).toFirestore());
  }

  Future<void> delete(MovementEntity m) async {
    final path = _getMovementsPath(m.billingPeriodId);
    await _firestore.collection(path).doc(m.id).delete();
  }

  Future<List<MovementEntity>> fetchByBillingPeriod(
    String billingPeriodId,
  ) async {
    final path = _getMovementsPath(billingPeriodId);
    final snapshot = await _firestore.collection(path).get();
    return snapshot.docs.map((doc) {
      return MovementModel.fromFirestore(doc.data(), doc.id);
    }).toList();
  }
}
