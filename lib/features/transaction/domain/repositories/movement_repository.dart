import 'package:cashify/features/transaction/data/models/movement_model.dart';
import 'package:cashify/features/transaction/domain/entities/movement_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MovementRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  MovementRepository(this._firestore, this._auth);

  String get _currentUid =>
      _auth.currentUser?.uid ?? (throw Exception("Usuario no autenticado"));

  DocumentReference<Map<String, dynamic>> _periodDoc(String billingPeriodId) {
    return _firestore
        .collection("users")
        .doc(_currentUid)
        .collection("billing_periods")
        .doc(billingPeriodId);
  }

  CollectionReference<Map<String, dynamic>> _movementsRef(
    String billingPeriodId,
  ) {
    return _periodDoc(billingPeriodId).collection("movements");
  }

  Future<void> save(MovementEntity m) async => saveMultiple([m]);

  Future<void> saveMultiple(List<MovementEntity> movements) async {
    if (movements.isEmpty) return;

    final batch = _firestore.batch();
    final updatedPeriods = <String>{};

    try {
      for (var m in movements) {
        final periodId = m.billingPeriodId;
        final periodRef = _periodDoc(periodId);
        final movementRef = _movementsRef(periodId).doc();

        if (!updatedPeriods.contains(periodId)) {
          batch.set(periodRef, {
            'id': periodId,
            'year': m.billingPeriodYear,
            'month': m.billingPeriodMonth,
            'lastUpdate': FieldValue.serverTimestamp(),
            'status': 'active',
          }, SetOptions(merge: true));
          updatedPeriods.add(periodId);
        }

        batch.set(
          movementRef,
          MovementModel.fromEntity(m).toFirestore(_currentUid),
        );
      }

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> update(MovementEntity m) async {
    try {
      await _movementsRef(
        m.billingPeriodId,
      ).doc(m.id).update(MovementModel.fromEntity(m).toFirestore(_currentUid));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateGroup(
    MovementEntity baseMovement,
    bool onlyPending,
  ) async {
    try {
      final snapshot = await _firestore
          .collectionGroup('movements')
          .where('groupId', isEqualTo: baseMovement.groupId)
          .get();

      final batch = _firestore.batch();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final bool isCompleted = data['isCompleted'];
        final String docId = doc.id;

        if (onlyPending && isCompleted && docId != baseMovement.id) {
          continue;
        }

        batch.update(doc.reference, {
          'description': baseMovement.description,
          'amount': baseMovement.amount,
          'categoryId': baseMovement.categoryId,
          'paymentMethodId': baseMovement.paymentMethodId,
          'source': baseMovement.source,
          if (docId == baseMovement.id) 'isCompleted': baseMovement.isCompleted,
        });
      }

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> delete(MovementEntity m) async {
    try {
      await _movementsRef(m.billingPeriodId).doc(m.id).delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteGroup(String groupId) async {
    try {
      final snapshot = await _firestore
          .collectionGroup('movements')
          .where('userId', isEqualTo: _currentUid)
          .where('groupId', isEqualTo: groupId)
          .get();

      if (snapshot.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<MovementEntity>> fetchByBillingPeriod(
    String billingPeriodId,
  ) async {
    try {
      final snapshot = await _movementsRef(billingPeriodId).get();

      return snapshot.docs
          .map((doc) {
            return MovementModel.fromFirestore(doc.data(), doc.id);
          })
          .cast<MovementEntity>()
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
