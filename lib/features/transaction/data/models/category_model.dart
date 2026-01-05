import 'package:cashify/features/transaction/domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  CategoryModel({
    required super.id,
    required super.name,
    required super.isExpense,
    required super.isExtra,
  });

  factory CategoryModel.fromFirestore(Map<String, dynamic> data, String id) {
    return CategoryModel(
      id: id,
      name: data['name'] ?? '',
      isExpense: data['isExpense'] ?? true,
      isExtra: data['isExtra'] ?? false, 
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'isExpense': isExpense,
      'isExtra': isExtra,
    };
  }
}