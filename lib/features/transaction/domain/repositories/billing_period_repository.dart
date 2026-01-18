import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BillingPeriodRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  BillingPeriodRepository(this._firestore, this._auth);

  CollectionReference<Map<String, dynamic>>? get _billingPeriodsRef {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("Usuario no autenticado");

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('billing_periods');
  }

  Future<List<String>> getAllPeriodIds() async {
    try {
      final ref = _billingPeriodsRef;
      if (ref == null) throw Exception('ref is null');
      final snapshot = await ref
          .orderBy('year', descending: true)
          .orderBy('month', descending: true)
          .get();

      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      rethrow;
    }
  }
}
