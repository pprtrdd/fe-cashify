import 'package:cashify/features/transaction/domain/entities/category_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.isExpense,
    required super.isExtra,
    required super.createdAt,
    required super.updatedAt,
    required super.isArchived,
  });

  factory CategoryModel.fromFirestore(Map<String, dynamic> json, String id) {
    return CategoryModel(
      id: id,
      name: json['name'].toString(),
      isExpense: json['isExpense'],
      isExtra: json['isExtra'],
      isArchived: json['isArchived'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'isExpense': isExpense,
      'isExtra': isExtra,
      'isArchived': isArchived,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory CategoryModel.fromEntity(CategoryEntity e) {
    return CategoryModel(
      id: e.id,
      name: e.name,
      isExpense: e.isExpense,
      isExtra: e.isExtra,
      isArchived: e.isArchived,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
    );
  }
}
