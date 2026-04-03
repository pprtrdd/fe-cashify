import 'package:cashify/core/utils/billing_period_utils.dart';
import 'package:cashify/features/transaction/domain/entities/category_entity.dart';
import 'package:cashify/features/transaction/domain/entities/transaction_entity.dart';
import 'package:cashify/features/transaction/domain/entities/payment_method_entity.dart';
import 'package:cashify/features/transaction/domain/usecases/category_usecases.dart';
import 'package:cashify/features/transaction/domain/usecases/transaction_usecases.dart';
import 'package:cashify/features/transaction/domain/usecases/payment_method_usecases.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionUseCase transactionUseCase;
  String? get lastLoadedBillingPeriodId => _lastLoadedBillingPeriodId;
  final CategoryUsecases categoryUsecases;
  final PaymentMethodUsecases paymentMethodUsecases;

  TransactionProvider({
    required this.transactionUseCase,
    required this.categoryUsecases,
    required this.paymentMethodUsecases,
  });

  bool _isLoading = false;

  List<CategoryEntity> _categories = [];
  List<TransactionEntity> _transactions = [];
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
  final int _pageSize = 10;

  String? _filterCategoryId;
  String? _filterPaymentMethodId;

  bool get isLoading => _isLoading;

  List<CategoryEntity> get categories => _categories;
  List<TransactionEntity> get transactions => _transactions;
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
  int get transactionsPerPage => _pageSize;

  bool get hasExtraCategories => _categories.any((c) => c.isExtra);
  Set<String> get incomeCategoryIds => _incomeCategoryIds;

  List<TransactionEntity> get filteredTransactions {
    return _transactions.where((m) {
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
  }

  List<TransactionEntity> get pagedFilteredTransactions {
    final fullList = filteredTransactions;
    final end = _currentPage * _pageSize;

    return fullList
        .take(end > fullList.length ? fullList.length : end)
        .toList();
  }

  String? get filterCategoryId => _filterCategoryId;
  String? get filterPaymentMethodId => _filterPaymentMethodId;

  void setCategoryId(String? id) {
    _filterCategoryId = id;
    _currentPage = 1;
    notifyListeners();
  }

  void setPaymentMethodId(String? id) {
    _filterPaymentMethodId = id;
    _currentPage = 1;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _currentPage = 1;
    notifyListeners();
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
      if (cat.isArchived) continue;
      if (cat.isExtra) {
        _extraGrouped[cat.name] = 0;
      } else {
        _plannedGrouped[cat.name] = 0;
      }
    }

    for (final mov in _transactions) {
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

  Future<void> _fetchTransactionsOnly(String billingPeriodId) async {
    _transactions = await transactionUseCase.fetchByBillingPeriodId(billingPeriodId);
    _calculateDashboardData();
    notifyListeners();
  }

  Future<void> loadDataByBillingPeriod(String billingPeriodId) async {
    if (_isLoading && _lastLoadedBillingPeriodId == billingPeriodId) return;

    _lastLoadedBillingPeriodId = billingPeriodId;
    _isLoading = true;
    _transactions = [];
    _resetTotals();
    notifyListeners();

    try {
      final results = await Future.wait([
        categoryUsecases.fetchAll(),
        paymentMethodUsecases.fetchAll(),
        transactionUseCase.fetchByBillingPeriodId(billingPeriodId),
      ]);

      _categories = results[0] as List<CategoryEntity>;
      _paymentMethods = results[1] as List<PaymentMethodEntity>;
      _transactions = results[2] as List<TransactionEntity>;

      _rebuildCategoryCache();
      _calculateDashboardData();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshData() async {
    if (_lastLoadedBillingPeriodId != null) {
      await loadDataByBillingPeriod(_lastLoadedBillingPeriodId!);
    }
  }

  Future<void> createTransaction(
    TransactionEntity transaction,
    String currentViewId,
    int startDay,
    VoidCallback onPeriodsCreated,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      final String groupId = const Uuid().v4();
      final baseTransaction = transaction.copyWith(groupId: groupId);
      List<TransactionEntity> transactionsToSave = [baseTransaction];

      if (transaction.totalInstallments > 1 &&
          transaction.currentInstallment < transaction.totalInstallments) {
        final int totalGenerar =
            transaction.totalInstallments - transaction.currentInstallment;

        for (int i = 1; i <= totalGenerar; i++) {
          final nextDate = DateTime(
            transaction.billingPeriodYear,
            transaction.billingPeriodMonth + i,
            2,
          );

          final nextBillingPeriodId = BillingPeriodUtils.generateId(
            nextDate,
            startDay,
          );

          transactionsToSave.add(
            baseTransaction.copyWith(
              id: '',
              currentInstallment: transaction.currentInstallment + i,
              billingPeriodYear: nextDate.year,
              billingPeriodMonth: nextDate.month,
              billingPeriodId: nextBillingPeriodId,
              isCompleted: false,
            ),
          );
        }
      }

      await transactionUseCase.addAll(transactionsToSave);
      onPeriodsCreated();
      await _fetchTransactionsOnly(currentViewId);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTransaction(TransactionEntity transaction) async {
    _isLoading = true;
    notifyListeners();

    try {
      await transactionUseCase.update(transaction);
      final index = _transactions.indexWhere((m) => m.id == transaction.id);

      if (index != -1) {
        _transactions[index] = transaction;
        _calculateDashboardData();
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTransactionGroup({
    required TransactionEntity baseTransaction,
    required bool onlyPending,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await transactionUseCase.updateGroup(baseTransaction, onlyPending);

      if (_lastLoadedBillingPeriodId != null) {
        await _fetchTransactionsOnly(_lastLoadedBillingPeriodId!);
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(TransactionEntity transaction) async {
    _isLoading = true;
    notifyListeners();

    try {
      await transactionUseCase.delete(transaction);
      _transactions.removeWhere((m) => m.id == transaction.id);
      _calculateDashboardData();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTransactionGroup(TransactionEntity transaction) async {
    if (transaction.groupId.isEmpty) {
      return deleteTransaction(transaction);
    }

    _isLoading = true;
    notifyListeners();

    try {
      await transactionUseCase.deleteGroup(
        transaction.billingPeriodId,
        transaction.groupId,
      );

      await _fetchTransactionsOnly(transaction.billingPeriodId);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleCompletion(TransactionEntity transaction) async {
    final updatedTransaction = transaction.copyWith(
      isCompleted: !transaction.isCompleted,
    );
    final index = _transactions.indexWhere((m) => m.id == transaction.id);
    if (index != -1) {
      _transactions[index] = updatedTransaction;
      _calculateDashboardData();
      notifyListeners();
    }

    try {
      await transactionUseCase.update(updatedTransaction);
    } catch (e) {
      if (_lastLoadedBillingPeriodId != null) {
        await loadDataByBillingPeriod(_lastLoadedBillingPeriodId!);
      }
    }
  }

  String getCategoryName(String id) {
    return _categoryMap[id]?.name ?? "Categoría no encontrada";
  }

  Future<void> confirmAndCompleteTransaction(
    TransactionEntity transaction,
    int finalAmount,
  ) async {
    _isLoading = true;
    notifyListeners();

    final updatedTransaction = transaction.copyWith(
      amount: finalAmount,
      isCompleted: true,
    );

    try {
      await transactionUseCase.update(updatedTransaction);
      final index = _transactions.indexWhere((m) => m.id == transaction.id);

      if (index != -1) {
        _transactions[index] = updatedTransaction;
        _transactions = List.from(_transactions);

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
    if (_currentPage * _pageSize < filteredTransactions.length) {
      _currentPage++;
      notifyListeners();
    }
  }

  TransactionEntity prepareCopy(TransactionEntity original) {
    return original.copyWith(id: '', groupId: '');
  }

  String getPaymentMethodName(String id) {
    return _paymentMethods
        .firstWhere(
          (pm) => pm.id == id,
          orElse: () => PaymentMethodEntity(id: '', name: 'Desconocido'),
        )
        .name;
  }
}
