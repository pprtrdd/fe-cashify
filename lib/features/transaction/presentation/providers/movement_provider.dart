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
  List<MovementEntity> _movements = [];
  List<PaymentMethodEntity> _paymentMethods = [];

  List<CategoryEntity> get categories => _categories;
  List<MovementEntity> get movements => _movements;
  List<PaymentMethodEntity> get paymentMethods => _paymentMethods;

  int _realTotal = 0;
  int _plannedTotal = 0;
  int _totalExtra = 0;
  Map<String, int> _plannedGrouped = {};
  Map<String, int> _extraGrouped = {};

  int get realTotal => _realTotal;
  int get plannedTotal => _plannedTotal;
  int get totalExtra => _totalExtra;
  Map<String, int> get plannedGrouped => _plannedGrouped;
  Map<String, int> get extraGrouped => _extraGrouped;
  bool get hasExtraCategories => _categories.any((c) => c.isExtra);

  MovementProvider({
    required this.movementUseCase,
    required this.categoryUsecases,
    required this.paymentMethodUsecases,
  });

  void _calculateDashboardData() {
    _realTotal = 0;
    _plannedTotal = 0;
    _totalExtra = 0;
    _plannedGrouped = {};
    _extraGrouped = {};

    if (_categories.isEmpty) {
      return;
    }

    for (var cat in _categories) {
      if (cat.isExtra) {
        _extraGrouped[cat.name] = 0;
      } else {
        _plannedGrouped[cat.name] = 0;
      }
    }

    for (var mov in _movements) {
      final catIndex = _categories.indexWhere((c) => c.id == mov.categoryId);

      final cat = _categories[catIndex];
      int value = cat.isExpense ? -mov.amount : mov.amount;

      _realTotal += value;

      if (cat.isExtra) {
        _extraGrouped[cat.name] = (_extraGrouped[cat.name] ?? 0) + value;
        _totalExtra += value;
      } else {
        _plannedGrouped[cat.name] = (_plannedGrouped[cat.name] ?? 0) + value;
        _plannedTotal += value;
      }
    }
  }

  Future<void> loadAllData() async {
    _isLoading = true;
    notifyListeners();
    try {
      _categories = await categoryUsecases.fetchAll();
      _paymentMethods = await paymentMethodUsecases.fetchAll();
      _movements = await movementUseCase.fetchByMonth(
        DateTime.now().year,
        DateTime.now().month,
      );

      _calculateDashboardData();
    } catch (e) {
      /* Handle error */
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCategories() => loadAllData();
  Future<void> loadMovementsByMonth() => loadAllData();
  Future<void> loadPaymentMethods() async {}

  Future<void> createMovement(MovementEntity movement) async {
    try {
      _isLoading = true;
      notifyListeners();

      await movementUseCase.add(movement);
      await loadAllData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
