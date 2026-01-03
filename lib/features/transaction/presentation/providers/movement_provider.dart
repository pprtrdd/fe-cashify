import 'package:cashify/features/transaction/domain/entities/category_entity.dart';
import 'package:cashify/features/transaction/domain/entities/movement_entity.dart';
import 'package:cashify/features/transaction/domain/entities/payment_method_entity.dart';
import 'package:cashify/features/transaction/domain/repositories/category_repository.dart';
import 'package:cashify/features/transaction/domain/repositories/payment_method_repository.dart';
import 'package:cashify/features/transaction/domain/usecases/movement_usecase.dart';
import 'package:flutter/material.dart';

class MovementProvider extends ChangeNotifier {
  final MovementUseCase _movementUseCase = MovementUseCase();
  final CategoryRepository categoryRepository;
  final PaymentMethodRepository paymentMethodRepository;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  List<CategoryEntity> _categories = [];
  List<CategoryEntity> get categories => _categories;
  List<PaymentMethodEntity> _paymentMethods = [];
  List<PaymentMethodEntity> get paymentMethods => _paymentMethods;

  MovementProvider({required this.categoryRepository, required this.paymentMethodRepository});

  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      _categories = await categoryRepository.fetchCategories();
    } catch (e) {
      /* Handle errors */
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPaymentMethods() async {
    _isLoading = true;
    notifyListeners();

    try {
      _paymentMethods = await paymentMethodRepository.fetchPaymentMethods();
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
