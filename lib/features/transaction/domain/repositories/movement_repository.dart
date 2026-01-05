import 'package:cashify/features/transaction/domain/entities/movement_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MovementRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> save(MovementEntity movement) async {
    final user = _auth.currentUser;

    try {
      if (user == null) throw Exception("Usuario no autenticado");

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('movements')
          .add({
            'categoryId': movement.categoryId,
            'description': movement.description,
            'source': movement.source,
            'quantity': movement.quantity,
            'amount': movement.amount,
            'currentInstallment': movement.currentInstallment,
            'totalInstallments': movement.totalInstallments,
            'paymentMethodId': movement.paymentMethodId,
            'billingPeriodYear': movement.billingPeriodYear,
            'billingPeriodMonth': movement.billingPeriodMonth,
            'notes': movement.notes,
            'createdAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      rethrow;
    }
  }

  Future<List<MovementEntity>> fetchByMonth(int year, int month) async {
    final user = _auth.currentUser;

    if (user == null) return [];

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('movements')
          .where('billingPeriodYear', isEqualTo: 2026)
          .where('billingPeriodMonth', isEqualTo: 1)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();

        return MovementEntity(
          categoryId: data['categoryId'] ?? '',
          description: data['description'] ?? '',
          source: data['source'] ?? '',
          quantity: (data['quantity'] as num?)?.toInt() ?? 0,
          amount: (data['amount'] as num?)?.toInt() ?? 0,
          currentInstallment:
              (data['currentInstallment'] as num?)?.toInt() ?? 0,
          totalInstallments: (data['totalInstallments'] as num?)?.toInt() ?? 0,
          paymentMethodId: data['paymentMethodId'] ?? '',
          billingPeriodYear: (data['billingPeriodYear'] as num?)?.toInt() ?? 0,
          billingPeriodMonth:
              (data['billingPeriodMonth'] as num?)?.toInt() ?? 0,
          notes: data['notes'],
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }
}
