import 'package:cashify/core/utils/billing_period_utils.dart';
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

  List<CategoryEntity> _categories = [];
  List<MovementEntity> _movements = [];
  List<PaymentMethodEntity> _paymentMethods = [];
  Map<String, CategoryEntity> _categoryMap = {};
  Set<String> _incomeCategoryIds = {};

  String? _lastLoadedBillingPeriodId;

  double _realTotal = 0;
  double _plannedTotal = 0;
  double _totalExtra = 0;
  double _totalIncomes = 0.0;
  double _totalExpenses = 0.0;

  Map<String, int> _plannedGrouped = {};
  Map<String, int> _extraGrouped = {};

  String _searchQuery = "";
  int _currentPage = 1;
  final int _pageSize = 20;

  String? _filterCategoryId;
  String? _filterPaymentMethodId;

  bool get isLoading => _isLoading;

  List<CategoryEntity> get categories => _categories;
  List<MovementEntity> get movements => _movements;
  List<PaymentMethodEntity> get paymentMethods => _paymentMethods;

  double get realTotal => _realTotal;
  double get totalBalance => _realTotal;
  double get plannedTotal => _plannedTotal;
  double get totalExtra => _totalExtra;
  double get totalIncomes => _totalIncomes;
  double get totalExpenses => _totalExpenses;

  Map<String, int> get plannedGrouped => _plannedGrouped;
  Map<String, int> get extraGrouped => _extraGrouped;

  String get searchQuery => _searchQuery;
  int get movementsPerPage => _pageSize;

  bool get hasExtraCategories => _categories.any((c) => c.isExtra);
  Set<String> get incomeCategoryIds => _incomeCategoryIds;

  List<MovementEntity> get filteredMovements {
    List<MovementEntity> list = _movements.where((m) {
      final matchesSearch =
          m.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          m.source.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (m.notes?.toLowerCase() ?? "").contains(_searchQuery.toLowerCase());

      final matchesCategory =
          _filterCategoryId == null || m.categoryId == _filterCategoryId;
      final matchesPayment =
          _filterPaymentMethodId == null ||
          m.paymentMethodId == _filterPaymentMethodId;

      return matchesSearch && matchesCategory && matchesPayment;
    }).toList();

    list.sort((a, b) => b.id.compareTo(a.id));

    return list;
  }

  List<MovementEntity> get pagedFilteredMovements {
    final fullList = filteredMovements;
    final end = _currentPage * _pageSize;

    return fullList
        .take(end > fullList.length ? fullList.length : end)
        .toList();
  }

  void _resetTotals() {
    _realTotal = 0;
    _plannedTotal = 0;
    _totalExtra = 0;
    _totalIncomes = 0.0;
    _totalExpenses = 0.0;
    _plannedGrouped = {};
    _extraGrouped = {};
  }

  void _calculateDashboardData() {
    _resetTotals();

    if (_categories.isEmpty) return;

    for (final cat in _categories) {
      if (cat.isExtra) {
        _extraGrouped[cat.name] = 0;
      } else {
        _plannedGrouped[cat.name] = 0;
      }
    }

    for (final mov in _movements) {
      if (!mov.isCompleted) continue;

      final cat = _categoryMap[mov.categoryId];
      if (cat == null) continue;

      final amount = mov.totalAmount;
      final double doubleAmount = amount.toDouble();

      if (cat.isExpense) {
        _totalExpenses += doubleAmount;
      } else {
        _totalIncomes += doubleAmount;
      }

      final int relativeValue = cat.isExpense ? -amount : amount;
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

  void _rebuildCategoryCache() {
    _categoryMap = {for (var c in _categories) c.id: c};
    _incomeCategoryIds = _categories
        .where((cat) => !cat.isExpense)
        .map((cat) => cat.id)
        .toSet();
  }

  Future<void> _fetchMovementsOnly(String billingPeriodId) async {
    _movements = await movementUseCase.fetchByBillingPeriod(billingPeriodId);
    _calculateDashboardData();
    notifyListeners();
  }

  Future<void> loadDataByBillingPeriod(String billingPeriodId) async {
    if (_isLoading && _lastLoadedBillingPeriodId == billingPeriodId) return;

    _lastLoadedBillingPeriodId = billingPeriodId;
    _isLoading = true;
    _movements = [];
    _resetTotals();
    notifyListeners();

    try {
      final results = await Future.wait([
        categoryUsecases.fetchAll(),
        paymentMethodUsecases.fetchAll(),
        movementUseCase.fetchByBillingPeriod(billingPeriodId),
      ]);

      _categories = results[0] as List<CategoryEntity>;
      _paymentMethods = results[1] as List<PaymentMethodEntity>;
      _movements = results[2] as List<MovementEntity>;

      _rebuildCategoryCache();
      _calculateDashboardData();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createMovement(
    MovementEntity movement,
    String currentViewId,
    int startDay,
    VoidCallback onPeriodsCreated,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      /* TODO: Move groupId setter to other layer */
      final String groupId = DateTime.now().millisecondsSinceEpoch.toString();
      List<MovementEntity> movementsToSave = [
        movement.copyWith(groupId: groupId),
      ];

      if (movement.totalInstallments > 1 && movement.currentInstallment == 1) {
        for (int i = 1; i < movement.totalInstallments; i++) {
          final nextDate = DateTime(
            movement.billingPeriodYear,
            movement.billingPeriodMonth + i,
            2,
          );

          final nextPeriodId = BillingPeriodUtils.generateId(
            nextDate,
            startDay,
          );

          movementsToSave.add(
            movement.copyWith(
              id: '',
              groupId: groupId,
              currentInstallment: i + 1,
              billingPeriodYear: nextDate.year,
              billingPeriodMonth: nextDate.month,
              billingPeriodId: nextPeriodId,
              isCompleted: false,
            ),
          );
        }
      }

      await movementUseCase.addAll(movementsToSave);
      onPeriodsCreated();
      await _fetchMovementsOnly(currentViewId);
    } catch (e) {
      rethrow;
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
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateMovementGroup({
    required MovementEntity baseMovement,
    required bool onlyPending,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await movementUseCase.updateGroup(baseMovement, onlyPending);

      if (_lastLoadedBillingPeriodId != null) {
        await _fetchMovementsOnly(_lastLoadedBillingPeriodId!);
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteMovement(MovementEntity movement) async {
    _isLoading = true;
    notifyListeners();

    try {
      await movementUseCase.delete(movement);
      _movements.removeWhere((m) => m.id == movement.id);
      _calculateDashboardData();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteMovementGroup(MovementEntity movement) async {
    if (movement.groupId.isEmpty) {
      return deleteMovement(movement);
    }

    _isLoading = true;
    notifyListeners();

    try {
      await movementUseCase.deleteGroup(
        movement.billingPeriodId,
        movement.groupId,
      );

      await _fetchMovementsOnly(movement.billingPeriodId);
    } catch (e) {
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
      if (_lastLoadedBillingPeriodId != null) {
        await loadDataByBillingPeriod(_lastLoadedBillingPeriodId!);
      }
    }
  }

  String getCategoryName(String id) {
    return _categoryMap[id]?.name ?? "Categoría no encontrada";
  }

  Future<void> confirmAndCompleteMovement(
    MovementEntity movement,
    int finalAmount,
  ) async {
    _isLoading = true;
    notifyListeners();

    final updatedMovement = movement.copyWith(
      amount: finalAmount,
      isCompleted: true,
    );

    try {
      await movementUseCase.update(updatedMovement);
      final index = _movements.indexWhere((m) => m.id == movement.id);

      if (index != -1) {
        _movements[index] = updatedMovement;
        _movements = List.from(_movements);

        _calculateDashboardData();
      }
    } catch (e) {
      if (_lastLoadedBillingPeriodId != null) {
        await loadDataByBillingPeriod(_lastLoadedBillingPeriodId!);
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilters({String? categoryId, String? paymentMethodId}) {
    _filterCategoryId = categoryId;
    _filterPaymentMethodId = paymentMethodId;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = "";
    _filterCategoryId = null;
    _filterPaymentMethodId = null;
    notifyListeners();
  }

  void loadNextPage() {
    if (_currentPage * _pageSize < filteredMovements.length) {
      _currentPage++;
      notifyListeners();
    }
  }

  MovementEntity prepareCopy(MovementEntity original) {
    /* TODO: Add createdAt field as empty string */
    return original.copyWith(id: '', groupId: '');
  }
}
