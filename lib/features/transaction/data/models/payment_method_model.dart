import 'package:cashify/features/transaction/domain/entities/payment_method_entity.dart';

class PaymentMethodModel extends PaymentMethodEntity {
  const PaymentMethodModel({required super.id, required super.name});

  factory PaymentMethodModel.fromFirestore(
    Map<String, dynamic> json,
    String docId,
  ) {
    return PaymentMethodModel(id: docId, name: json['name'].toString());
  }

  Map<String, dynamic> toFirestore() {
    return {'name': name};
  }

  factory PaymentMethodModel.fromEntity(PaymentMethodEntity entity) {
    return PaymentMethodModel(id: entity.id, name: entity.name);
  }
}
