import 'package:cashify/features/transaction/domain/entities/category_entity.dart';
import 'package:cashify/features/transaction/domain/entities/movement_entity.dart';
import 'package:cashify/features/transaction/domain/entities/payment_method_entity.dart';
import 'package:cashify/features/transaction/domain/usecases/category_usecases.dart';
import 'package:cashify/features/transaction/domain/usecases/movement_usecases.dart';
import 'package:cashify/features/transaction/domain/usecases/payment_method_usecases.dart';
import 'package:flutter/material.dart';

class MovementProvider extends ChangeNotifier {
  final MovementUseCase movementUseCase;
  final CategoryUsecases categoryUsecases;
  final PaymentMethodUsecases paymentMethodUsecases;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  List<CategoryEntity> _categories = [];
  List<CategoryEntity> get categories => _categories;
  List<PaymentMethodEntity> _paymentMethods = [];
  List<PaymentMethodEntity> get paymentMethods => _paymentMethods;

  MovementProvider({
    required this.movementUseCase,
    required this.categoryUsecases,
    required this.paymentMethodUsecases,
  });

  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      _categories = await categoryUsecases.fetchAll();
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
      _paymentMethods = await paymentMethodUsecases.fetchAll();
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
      await movementUseCase.add(movement);
    } catch (e) {
      /* Handle errors */
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
