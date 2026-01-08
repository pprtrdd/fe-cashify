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

  MovementProvider({
    required this.movementUseCase,
    required this.categoryUsecases,
    required this.paymentMethodUsecases,
  });

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
  double _totalIncomes = 0.0;
  double _totalExpenses = 0.0;

  Map<String, int> _plannedGrouped = {};
  Map<String, int> _extraGrouped = {};

  int get realTotal => _realTotal;
  double get totalBalance => _realTotal.toDouble();
  double get totalIncomes => _totalIncomes;
  double get totalExpenses => _totalExpenses;
  int get plannedTotal => _plannedTotal;
  int get totalExtra => _totalExtra;
  Map<String, int> get plannedGrouped => _plannedGrouped;
  Map<String, int> get extraGrouped => _extraGrouped;
  bool get hasExtraCategories => _categories.any((c) => c.isExtra);
  Set<String> get incomeCategoryIds {
    return _categories
        .where((cat) => !cat.isExpense)
        .map((cat) => cat.id)
        .toSet();
  }

  void _calculateDashboardData() {
    _realTotal = 0;
    _plannedTotal = 0;
    _totalExtra = 0;
    _totalIncomes = 0.0;
    _totalExpenses = 0.0;
    _plannedGrouped = {};
    _extraGrouped = {};

    if (_categories.isEmpty) return;

    for (var cat in _categories) {
      if (cat.isExtra) {
        _extraGrouped[cat.name] = 0;
      } else {
        _plannedGrouped[cat.name] = 0;
      }
    }

    final completedMovements = _movements.where((m) => m.isCompleted);

    for (var mov in completedMovements) {
      final cat = _categories.cast<CategoryEntity?>().firstWhere(
        (c) => c?.id == mov.categoryId,
      );

      if (cat == null) continue;

      if (cat.isExpense) {
        _totalExpenses += mov.totalAmount.toDouble();
      } else {
        _totalIncomes += mov.totalAmount.toDouble();
      }

      int relativeValue = cat.isExpense ? -mov.totalAmount : mov.totalAmount;
      _realTotal += relativeValue;

      if (cat.isExtra) {
        _extraGrouped[cat.name] =
            (_extraGrouped[cat.name] ?? 0) + relativeValue;
        _totalExtra += relativeValue;
      } else {
        _plannedGrouped[cat.name] =
            (_plannedGrouped[cat.name] ?? 0) + relativeValue;
        _plannedTotal += relativeValue;
      }
    }
  }

  Future<void> loadAllData() async {
    _isLoading = true;
    notifyListeners();
    try {
      final now = DateTime.now();
      final results = await Future.wait([
        categoryUsecases.fetchAll(),
        paymentMethodUsecases.fetchAll(),
        movementUseCase.fetchByMonth(now.year, now.month),
      ]);

      _categories = results[0] as List<CategoryEntity>;
      _paymentMethods = results[1] as List<PaymentMethodEntity>;
      _movements = results[2] as List<MovementEntity>;

      _calculateDashboardData();
    } catch (e) {
      debugPrint("Error al cargar datos: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createMovement(MovementEntity movement) async {
    try {
      _isLoading = true;
      notifyListeners();

      await movementUseCase.add(movement);
      await loadAllData();
    } catch (e) {
      debugPrint("Error al crear movimiento: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateMovement(MovementEntity movement) async {
    _isLoading = true;
    notifyListeners();

    try {
      await movementUseCase.update(movement);

      final index = _movements.indexWhere((m) => m.id == movement.id);
      if (index != -1) {
        _movements[index] = movement;
        _calculateDashboardData();
      }
    } catch (e) {
      debugPrint("Error al actualizar movimiento: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteMovement(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await movementUseCase.delete(id);
      _movements.removeWhere((m) => m.id == id);
      _calculateDashboardData();
    } catch (e) {
      debugPrint("Error al eliminar movimiento: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleCompletion(MovementEntity movement) async {
    final updatedMovement = movement.copyWith(
      isCompleted: !movement.isCompleted,
    );
    final index = _movements.indexWhere((m) => m.id == movement.id);

    if (index != -1) {
      _movements[index] = updatedMovement;
      _calculateDashboardData();
      notifyListeners();
    }

    try {
      await movementUseCase.update(updatedMovement);
    } catch (e) {
      await loadAllData();
      debugPrint("Error al sincronizar estado: $e");
    }
  }

  String getCategoryName(String id) {
    try {
      return _categories.firstWhere((cat) => cat.id == id).name;
    } catch (_) {
      return "Categoría no encontrada";
    }
  }
}
