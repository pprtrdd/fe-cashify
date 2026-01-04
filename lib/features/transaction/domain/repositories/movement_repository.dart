import 'package:cashify/features/transaction/domain/entities/movement_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MovementRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveMovement(MovementEntity movement) async {
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
}
