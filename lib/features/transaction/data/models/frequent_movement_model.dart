import 'package:cashify/features/transaction/domain/entities/frequent_movement_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FrequentMovementModel extends FrequentMovementEntity {
  const FrequentMovementModel({
    required super.id,
    required super.categoryId,
    required super.description,
    required super.source,
    required super.amount,
    required super.frequency,
    required super.paymentDay,
    required super.isArchived,
    required super.createdAt,
    required super.updatedAt,
  });

  factory FrequentMovementModel.fromFirestore(
    Map<String, dynamic> json,
    String docId,
  ) {
    return FrequentMovementModel(
      id: docId,
      categoryId: json['categoryId'],
      description: json['description'],
      source: json['source'],
      amount: (json['amount'] as num).toInt(),
      frequency: FrequentFrequency.fromMonths(
        (json['frequency'] as num).toInt(),
      ),
      paymentDay: (json['paymentDay'] as num).toInt(),
      isArchived: json['isArchived'] ?? false,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'categoryId': categoryId,
      'description': description,
      'source': source,
      'amount': amount,
      'frequency': frequency.months,
      'paymentDay': paymentDay,
      'isArchived': isArchived,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory FrequentMovementModel.fromEntity(FrequentMovementEntity e) {
    return FrequentMovementModel(
      id: e.id,
      categoryId: e.categoryId,
      description: e.description,
      source: e.source,
      amount: e.amount,
      frequency: e.frequency,
      paymentDay: e.paymentDay,
      isArchived: e.isArchived,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
    );
  }
}
