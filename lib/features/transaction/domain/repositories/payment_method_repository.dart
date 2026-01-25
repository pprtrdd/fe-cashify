import 'package:cashify/features/transaction/data/models/payment_method_model.dart';
import 'package:cashify/features/transaction/domain/entities/payment_method_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentMethodRepository {
  final FirebaseFirestore _firestore;

  PaymentMethodRepository(this._firestore);

  CollectionReference? get _paymentMethodsRef {
    return _firestore.collection('payment_methods');
  }

  Future<List<PaymentMethodEntity>> fetchPaymentMethods() async {
    try {
      final ref = _paymentMethodsRef;
      if (ref == null) throw Exception('ref is null');
      final snapshot = await ref.orderBy('name').get();

      return snapshot.docs
          .map(
            (doc) => PaymentMethodModel.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .cast<PaymentMethodEntity>()
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
