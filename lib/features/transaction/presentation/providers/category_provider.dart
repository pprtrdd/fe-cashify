import 'package:cashify/features/transaction/domain/entities/category_entity.dart';
import 'package:cashify/features/transaction/domain/usecases/category_usecases.dart';
import 'package:flutter/material.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryUsecases categoryUsecases;

  CategoryProvider({required this.categoryUsecases});

  List<CategoryEntity> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<CategoryEntity> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await categoryUsecases.fetchAll();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addCategory({
    required String name,
    required bool isExpense,
    required bool isExtra,
  }) async {
    try {
      final newCategory = await categoryUsecases.add(
        name: name,
        isExpense: isExpense,
        isExtra: isExtra,
      );
      _categories = [..._categories, newCategory]
        ..sort((a, b) => a.name.compareTo(b.name));
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> hasMovements(String categoryId) async {
    return categoryUsecases.hasMovements(categoryId);
  }

  Future<bool> deleteCategory(String categoryId) async {
    try {
      await categoryUsecases.delete(categoryId);
      _categories = _categories.where((c) => c.id != categoryId).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> migrateMovements({
    required String fromCategoryId,
    required String toCategoryId,
  }) async {
    try {
      await categoryUsecases.migrateMovements(
        fromCategoryId: fromCategoryId,
        toCategoryId: toCategoryId,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> migrateAndDelete({
    required String fromCategoryId,
    required String toCategoryId,
  }) async {
    try {
      await categoryUsecases.migrateMovementsAndDelete(
        fromCategoryId: fromCategoryId,
        toCategoryId: toCategoryId,
      );
      _categories = _categories.where((c) => c.id != fromCategoryId).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCategory({
    required CategoryEntity category,
    required String name,
    required bool isExpense,
    required bool isExtra,
  }) async {
    try {
      await categoryUsecases.update(
        id: category.id,
        name: name,
        isExpense: isExpense,
        isExtra: isExtra,
      );

      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = category.copyWith(
          name: name,
          isExpense: isExpense,
          isExtra: isExtra,
        );
        _categories.sort((a, b) => a.name.compareTo(b.name));
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> archiveCategory(
    String categoryId, {
    required bool isArchived,
  }) async {
    try {
      await categoryUsecases.archive(categoryId, isArchived: isArchived);
      final index = _categories.indexWhere((c) => c.id == categoryId);
      if (index != -1) {
        _categories[index] = _categories[index].copyWith(
          isArchived: isArchived,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
