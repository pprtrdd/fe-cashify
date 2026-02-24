import 'package:cashify/core/utils/billing_period_utils.dart';
import 'package:cashify/features/transaction/domain/usecases/billing_period_usecases.dart';
import 'package:flutter/material.dart';

class BillingPeriodProvider extends ChangeNotifier {
  final BillingPeriodUsecases usecases;

  List<String> _periods = [];
  String? _selectedPeriodId;
  bool _isLoading = false;

  BillingPeriodProvider({required this.usecases});

  List<String> get periods => _periods;
  bool get isLoading => _isLoading;
  int _startDay = 0;

  void updateStartDay(int startDay) {
    if (_startDay != startDay) {
      _startDay = startDay;
      _selectedPeriodId = null;
      notifyListeners();
    }
  }

  String get selectedPeriodId {
    if (_selectedPeriodId == null) {
      _selectedPeriodId = BillingPeriodUtils.generateId(
        DateTime.now(),
        _startDay,
      );
      Future.microtask(() => notifyListeners());
    }
    return _selectedPeriodId!;
  }

  DateTimeRange getRangeFromId(String periodId, int startDay) {
    final parts = periodId.split('_');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);

    final end = DateTime(year, month, startDay - 1);
    final start = DateTime(year, month - 1, startDay);

    return DateTimeRange(start: start, end: end);
  }

  String formatId(String id) {
    final parts = id.split('_');
    if (parts.length != 2) return id;
    final year = parts[0];
    final monthIndex = int.parse(parts[1]) - 1;
    final months = [
      "Ene",
      "Feb",
      "Mar",
      "Abr",
      "May",
      "Jun",
      "Jul",
      "Ago",
      "Sep",
      "Oct",
      "Nov",
      "Dic",
    ];
    return "${months[monthIndex]} $year";
  }

  void selectPeriod(String periodId) {
    if (_selectedPeriodId == periodId) return;

    _selectedPeriodId = periodId;
    notifyListeners();
  }

  Future<void> loadPeriods() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      _periods = await usecases.fetchAll();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
