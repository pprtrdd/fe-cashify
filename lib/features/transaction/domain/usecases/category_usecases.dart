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

  Future<bool> hasTransactions(String categoryId) =>
      repository.checkCategoryHasTransactions(categoryId);

  Future<void> delete(String categoryId) =>
      repository.deleteCategory(categoryId);

  Future<void> migrateTransactions({
    required String fromCategoryId,
    required String toCategoryId,
  }) => repository.migrateTransactions(
    fromCategoryId: fromCategoryId,
    toCategoryId: toCategoryId,
  );

  Future<void> migrateTransactionsAndDelete({
    required String fromCategoryId,
    required String toCategoryId,
  }) => repository.migrateTransactionsAndDelete(
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

  Future<void> archive(String id, {required bool isArchived}) =>
      repository.archiveCategory(id, isArchived: isArchived);
}
