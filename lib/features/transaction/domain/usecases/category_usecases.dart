import 'package:cashify/features/transaction/domain/entities/category_entity.dart';
import 'package:cashify/features/transaction/domain/repositories/category_repository.dart';

class CategoryUsecases {
  final CategoryRepository repository;

  CategoryUsecases({required this.repository});

  Future<List<CategoryEntity>> fetchAll() => repository.fetchCategories();

  Future<CategoryEntity> add({
    required String name,
    required bool isExpense,
    required bool isExtra,
  }) => repository.addCategory(
    name: name,
    isExpense: isExpense,
    isExtra: isExtra,
  );

  Future<bool> hasMovements(String categoryId) =>
      repository.checkCategoryHasMovements(categoryId);

  Future<void> delete(String categoryId) =>
      repository.deleteCategory(categoryId);

  Future<void> migrateMovements({
    required String fromCategoryId,
    required String toCategoryId,
  }) => repository.migrateMovements(
    fromCategoryId: fromCategoryId,
    toCategoryId: toCategoryId,
  );

  Future<void> migrateMovementsAndDelete({
    required String fromCategoryId,
    required String toCategoryId,
  }) => repository.migrateMovementsAndDelete(
    fromCategoryId: fromCategoryId,
    toCategoryId: toCategoryId,
  );

  Future<void> update({
    required String id,
    required String name,
    required bool isExpense,
    required bool isExtra,
  }) => repository.updateCategory(
    id: id,
    name: name,
    isExpense: isExpense,
    isExtra: isExtra,
  );
}
