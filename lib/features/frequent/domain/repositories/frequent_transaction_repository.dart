import 'package:cashify/features/frequent/data/models/frequent_transaction_model.dart';
import 'package:cashify/features/frequent/domain/entities/frequent_transaction_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FrequentTransactionRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FrequentTransactionRepository(this._firestore, this._auth);

  String get _currentUid =>
      _auth.currentUser?.uid ?? (throw Exception("Usuario no autenticado"));

  CollectionReference<Map<String, dynamic>> get _frequentRef =>
      _firestore.collection("users").doc(_currentUid).collection("frequent");

  Future<void> save(FrequentTransactionEntity f) async {
    try {
      if (f.id.isEmpty) {
        await _frequentRef.add(
          FrequentTransactionModel.fromEntity(f).toFirestore(),
        );
      } else {
        await _frequentRef
            .doc(f.id)
            .set(
              FrequentTransactionModel.fromEntity(f).toFirestore(),
              SetOptions(merge: true),
            );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> update(FrequentTransactionEntity f) async {
    try {
      await _frequentRef
          .doc(f.id)
          .update(FrequentTransactionModel.fromEntity(f).toFirestore());
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

  Future<List<FrequentTransactionEntity>> fetchAll() async {
    try {
      final snapshot = await _frequentRef
          .where('isArchived', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FrequentTransactionModel.fromFirestore(doc.data(), doc.id))
          .cast<FrequentTransactionEntity>()
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
