import 'package:cashify/features/transaction/domain/entities/movement_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MovementModel extends MovementEntity {
  const MovementModel({
    required super.id,
    required super.userId,
    required super.groupId,
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
    required super.billingPeriodId,
    super.notes,
    required super.isCompleted,
  });

  factory MovementModel.fromFirestore(Map<String, dynamic> json, String docId) {
    return MovementModel(
      id: docId,
      userId: json['userId'],
      groupId: json['groupId'],
      categoryId: json['categoryId'],
      description: json['description'],
      source: json['source'],
      quantity: (json['quantity'] as num).toInt(),
      amount: (json['amount'] as num).toInt(),
      currentInstallment: (json['currentInstallment'] as num).toInt(),
      totalInstallments: (json['totalInstallments'] as num).toInt(),
      paymentMethodId: json['paymentMethodId'].toString(),
      billingPeriodMonth: (json['billingPeriodMonth'] as num).toInt(),
      billingPeriodYear: (json['billingPeriodYear'] as num).toInt(),
      billingPeriodId: json['billingPeriodId'],
      notes: json['notes']?.toString(),
      isCompleted: json['isCompleted'],
    );
  }

  Map<String, dynamic> toFirestore(String uid) {
    return {
      'userId': uid,
      'categoryId': categoryId,
      'groupId': groupId,
      'description': description,
      'source': source,
      'quantity': quantity,
      'amount': amount,
      'currentInstallment': currentInstallment,
      'totalInstallments': totalInstallments,
      'paymentMethodId': paymentMethodId,
      'billingPeriodMonth': billingPeriodMonth,
      'billingPeriodYear': billingPeriodYear,
      'billingPeriodId': billingPeriodId,
      'notes': notes,
      'isCompleted': isCompleted,
      /* TODO: Create updatedAt field */
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory MovementModel.fromEntity(MovementEntity e) {
    return MovementModel(
      id: e.id,
      userId: e.userId,
      groupId: e.groupId,
      categoryId: e.categoryId,
      description: e.description,
      source: e.source,
      quantity: e.quantity,
      amount: e.amount,
      currentInstallment: e.currentInstallment,
      totalInstallments: e.totalInstallments,
      paymentMethodId: e.paymentMethodId,
      billingPeriodMonth: e.billingPeriodMonth,
      billingPeriodYear: e.billingPeriodYear,
      billingPeriodId: e.billingPeriodId,
      notes: e.notes,
      isCompleted: e.isCompleted,
    );
  }
}
