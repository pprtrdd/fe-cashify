import 'package:cashify/features/transaction/data/models/movement_model.dart';
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
          .add(
            MovementModel(
              categoryId: movement.categoryId,
              description: movement.description,
              source: movement.source,
              quantity: movement.quantity,
              amount: movement.amount,
              currentInstallment: movement.currentInstallment,
              totalInstallments: movement.totalInstallments,
              paymentMethodId: movement.paymentMethodId,
              billingPeriodMonth: movement.billingPeriodMonth,
              billingPeriodYear: movement.billingPeriodYear,
              notes: movement.notes,
              isCompleted: movement.isCompleted,
            ).toFirestore(),
          );
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
          .where('billingPeriodMonth', isEqualTo: month)
          .where('billingPeriodYear', isEqualTo: year)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return MovementModel.fromFirestore(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }
}
