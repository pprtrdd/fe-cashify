import 'package:cashify/features/transaction/domain/entities/movement_entity.dart';

class MovementModel extends MovementEntity {
  MovementModel({
    required super.amount,
    required super.quantity,
    required super.currentInstallment,
    required super.totalInstallments,
    required super.billingPeriodMonth,
    required super.billingPeriodYear,
    required super.description,
    required super.source,
    required super.categoryId,
    required super.paymentMethodId,
  });

  factory MovementModel.fromFirestore(Map<String, dynamic> json, String docId) {
    return MovementModel(
      amount: json['amount'],
      quantity: json['quantity'],
      currentInstallment: json['currentInstallment'],
      totalInstallments: json['totalInstallments'],
      billingPeriodMonth: json['billingPeriodMonth'],
      billingPeriodYear: json['billingPeriodYear'],
      description: json['description'],
      source: json['source'],
      categoryId: json['categoryId'],
      paymentMethodId: json['paymentMethodId'],
    );
  }
}
