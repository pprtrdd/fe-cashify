import 'package:cashify/features/transaction/domain/entities/payment_method_entity.dart';
import 'package:cashify/features/transaction/data/models/payment_method_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentMethodRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<PaymentMethodEntity>> fetchPaymentMethods() async {
    final snapshot = await _firestore
        .collection('payment_methods')
        .orderBy('name')
        .get();

    return snapshot.docs
        .map((doc) => PaymentMethodModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }
}