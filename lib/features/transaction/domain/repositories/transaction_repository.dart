import 'package:cashify/features/transaction/data/models/transaction_model.dart';
import 'package:cashify/features/transaction/domain/entities/transaction_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/* TODO: Rename collection 'movements' to 'transactions' */
class TransactionRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  TransactionRepository(this._firestore, this._auth);

  String get _currentUid =>
      _auth.currentUser?.uid ?? (throw Exception("Usuario no autenticado"));

  DocumentReference<Map<String, dynamic>> _billingPeriodDoc(
    String billingPeriodId,
  ) {
    return _firestore
        .collection("users")
        .doc(_currentUid)
        .collection("billing_periods")
        .doc(billingPeriodId);
  }

  CollectionReference<Map<String, dynamic>> _transactionsRef(
    String billingPeriodId,
  ) {
    return _billingPeriodDoc(billingPeriodId).collection('movements');
  }

  Future<void> save(TransactionEntity m) async => saveMultiple([m]);

  Future<void> saveMultiple(List<TransactionEntity> transactions) async {
    if (transactions.isEmpty) return;

    final batch = _firestore.batch();
    final updatedPeriods = <String>{};

    try {
      for (var m in transactions) {
        final billingPeriodId = m.billingPeriodId;
        final billingPeriodRef = _billingPeriodDoc(billingPeriodId);
        final transactionRef = _transactionsRef(billingPeriodId).doc();

        if (!updatedPeriods.contains(billingPeriodId)) {
          batch.set(billingPeriodRef, {
            'id': billingPeriodId,
            'year': m.billingPeriodYear,
            'month': m.billingPeriodMonth,
            'lastUpdate': FieldValue.serverTimestamp(),
            'status': 'active',
          }, SetOptions(merge: true));
          updatedPeriods.add(billingPeriodId);
        }

        batch.set(
          transactionRef,
          TransactionModel.fromEntity(m).toFirestore(_currentUid),
        );
      }

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> update(TransactionEntity m) async {
    try {
      await _transactionsRef(m.billingPeriodId)
          .doc(m.id)
          .update(TransactionModel.fromEntity(m).toFirestore(_currentUid));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateGroup(
    TransactionEntity baseTransaction,
    bool onlyPending,
  ) async {
    try {
      final snapshot = await _firestore
          .collectionGroup('movements')
          .where('groupId', isEqualTo: baseTransaction.groupId)
          .get();

      final batch = _firestore.batch();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final bool isCompleted = data['isCompleted'];
        final String docId = doc.id;

        if (onlyPending && isCompleted && docId != baseTransaction.id) {
          continue;
        }

        batch.update(doc.reference, {
          'description': baseTransaction.description,
          'amount': baseTransaction.amount,
          'categoryId': baseTransaction.categoryId,
          'paymentMethodId': baseTransaction.paymentMethodId,
          'source': baseTransaction.source,
          if (docId == baseTransaction.id)
            'isCompleted': baseTransaction.isCompleted,
        });
      }

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> delete(TransactionEntity m) async {
    try {
      await _transactionsRef(m.billingPeriodId).doc(m.id).delete();
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

  Future<List<TransactionEntity>> fetchByBillingPeriodId(
    String billingPeriodId,
  ) async {
    try {
      final snapshot = await _transactionsRef(
        billingPeriodId,
      ).orderBy('createdAt', descending: true).get();

      return snapshot.docs
          .map((doc) {
            return TransactionModel.fromFirestore(doc.data(), doc.id);
          })
          .cast<TransactionEntity>()
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, String>> fetchLastTransactionsPerFrequent() async {
    try {
      final snapshot = await _firestore
          .collectionGroup('movements')
          .where('userId', isEqualTo: _currentUid)
          .where('frequentId', isGreaterThan: '')
          .orderBy('frequentId')
          .orderBy('createdAt', descending: true)
          .get();
      final Map<String, String> lastPeriods = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final frequentId = data['frequentId'] as String;
        final billingPeriodId = data['billingPeriodId'] as String;

        if (!lastPeriods.containsKey(frequentId)) {
          lastPeriods[frequentId] = billingPeriodId;
        }
      }
      return lastPeriods;
    } catch (e) {
      rethrow;
    }
  }
}
