import 'package:cashify/features/transaction/domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  CategoryModel({
    required super.id,
    required super.name,
    required super.isExpense,
  });

  factory CategoryModel.fromFirestore(Map<String, dynamic> json, String docId) {
    return CategoryModel(
      id: docId,
      name: json['name'],
      isExpense: (json['isExpense'] == true),
    );
  }
}
