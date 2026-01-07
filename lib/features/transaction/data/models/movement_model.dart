import 'package:cashify/features/transaction/domain/entities/movement_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MovementModel extends MovementEntity {
  const MovementModel({
    required super.id,
    required super.categoryId,
    required super.description,
    required super.source,
    required super.quantity,
    required super.amount,
    required super.currentInstallment,
    required super.totalInstallments,
    required super.paymentMethodId,
    required super.billingPeriodMonth,
    required super.billingPeriodYear,
    super.notes,
    required super.isCompleted,
  });

  factory MovementModel.fromFirestore(Map<String, dynamic> json, String docId) {
    return MovementModel(
      id: docId,
      categoryId: json['categoryId']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      currentInstallment: (json['currentInstallment'] as num?)?.toInt() ?? 0,
      totalInstallments: (json['totalInstallments'] as num?)?.toInt() ?? 0,
      paymentMethodId: json['paymentMethodId']?.toString() ?? '',
      billingPeriodMonth: (json['billingPeriodMonth'] as num?)?.toInt() ?? 0,
      billingPeriodYear: (json['billingPeriodYear'] as num?)?.toInt() ?? 0,
      notes: json['notes']?.toString(),
      isCompleted: json['isCompleted'] is bool ? json['isCompleted'] : false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'categoryId': categoryId,
      'description': description,
      'source': source,
      'quantity': quantity,
      'amount': amount,
      'currentInstallment': currentInstallment,
      'totalInstallments': totalInstallments,
      'paymentMethodId': paymentMethodId,
      'billingPeriodMonth': billingPeriodMonth,
      'billingPeriodYear': billingPeriodYear,
      'notes': notes,
      'isCompleted': isCompleted,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
