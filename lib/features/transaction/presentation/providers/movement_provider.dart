import 'package:cashify/features/transaction/domain/entities/category_entity.dart';
import 'package:cashify/features/transaction/domain/entities/movement_entity.dart';
import 'package:cashify/features/transaction/domain/repositories/category_repository.dart';
import 'package:cashify/features/transaction/domain/usecases/movement_usecase.dart';
import 'package:flutter/material.dart';

class MovementProvider extends ChangeNotifier {
  final MovementUseCase _movementUseCase = MovementUseCase();
  final CategoryRepository repository;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  List<CategoryEntity> _categories = [];
  List<CategoryEntity> get categories => _categories;

  MovementProvider({required this.repository});

  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      _categories = await repository.fetchCategories();
    } catch (e) {
      /* Handle errors */
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createMovement(MovementEntity movement) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _movementUseCase.add(movement);
    } catch (e) {
      /* Handle errors */
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
