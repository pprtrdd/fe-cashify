import 'package:cashify/features/transaction/domain/entities/payment_method_entity.dart';

class PaymentMethodModel extends PaymentMethodEntity {
  PaymentMethodModel({required super.id, required super.name});

  factory PaymentMethodModel.fromFirestore(
    Map<String, dynamic> json,
    String docId,
  ) {
    return PaymentMethodModel(id: docId, name: json['name']);
  }
}
