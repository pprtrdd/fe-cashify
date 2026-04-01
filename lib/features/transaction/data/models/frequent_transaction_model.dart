import 'package:cashify/features/transaction/domain/entities/frequent_transaction_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FrequentTransactionModel extends FrequentTransactionEntity {
  const FrequentTransactionModel({
    required super.id,
    required super.categoryId,
    required super.description,
    required super.source,
    required super.amount,
    required super.frequency,
    required super.isArchived,
    required super.createdAt,
    required super.updatedAt,
  });

  factory FrequentTransactionModel.fromFirestore(
    Map<String, dynamic> json,
    String docId,
  ) {
    return FrequentTransactionModel(
      id: docId,
      categoryId: json['categoryId'],
      description: json['description'],
      source: json['source'],
      amount: (json['amount'] as num).toInt(),
      frequency: FrequentFrequency.fromMonths(
        (json['frequency'] as num).toInt(),
      ),
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
      'isArchived': isArchived,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory FrequentTransactionModel.fromEntity(FrequentTransactionEntity e) {
    return FrequentTransactionModel(
      id: e.id,
      categoryId: e.categoryId,
      description: e.description,
      source: e.source,
      amount: e.amount,
      frequency: e.frequency,
      isArchived: e.isArchived,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
    );
  }
}
