import 'package:cashify/features/transaction/domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.isExpense,
    required super.isExtra,
  });

  factory CategoryModel.fromFirestore(Map<String, dynamic> json, String id) {
    return CategoryModel(
      id: id,
      name: json['name'].toString(),
      isExpense: json['isExpense'],
      isExtra: json['isExtra'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'name': name, 'isExpense': isExpense, 'isExtra': isExtra};
  }

  factory CategoryModel.fromEntity(CategoryEntity e) {
    return CategoryModel(
      id: e.id,
      name: e.name,
      isExpense: e.isExpense,
      isExtra: e.isExtra,
    );
  }
}
