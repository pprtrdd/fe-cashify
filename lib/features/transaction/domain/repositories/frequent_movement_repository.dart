import 'package:cashify/features/transaction/data/models/frequent_movement_model.dart';
import 'package:cashify/features/transaction/domain/entities/frequent_movement_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FrequentMovementRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FrequentMovementRepository(this._firestore, this._auth);

  String get _currentUid =>
      _auth.currentUser?.uid ?? (throw Exception("Usuario no autenticado"));

  CollectionReference<Map<String, dynamic>> get _frequentRef =>
      _firestore.collection("users").doc(_currentUid).collection("frequent");

  Future<void> save(FrequentMovementEntity f) async {
    try {
      if (f.id.isEmpty) {
        await _frequentRef.add(
          FrequentMovementModel.fromEntity(f).toFirestore(),
        );
      } else {
        await _frequentRef
            .doc(f.id)
            .set(
              FrequentMovementModel.fromEntity(f).toFirestore(),
              SetOptions(merge: true),
            );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> update(FrequentMovementEntity f) async {
    try {
      await _frequentRef
          .doc(f.id)
          .update(FrequentMovementModel.fromEntity(f).toFirestore());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> archive(String id) async {
    try {
      await _frequentRef.doc(id).update({
        'isArchived': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<List<FrequentMovementEntity>> fetchAll() async {
    try {
      final snapshot = await _frequentRef
          .where('isArchived', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FrequentMovementModel.fromFirestore(doc.data(), doc.id))
          .cast<FrequentMovementEntity>()
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
