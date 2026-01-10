import 'package:cashify/features/transaction/domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.isExpense,
    required super.isExtra,
  });

  factory CategoryModel.fromFirestore(Map<String, dynamic> data, String id) {
    return CategoryModel(
      id: id,
      name: data['name']?.toString() ?? 'Sin nombre',
      isExpense: data['isExpense'] is bool ? data['isExpense'] : true,
      isExtra: data['isExtra'] is bool ? data['isExtra'] : false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'name': name, 'isExpense': isExpense, 'isExtra': isExtra};
  }

  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      isExpense: entity.isExpense,
      isExtra: entity.isExtra,
    );
  }
}
