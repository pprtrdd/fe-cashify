import 'package:cashify/features/configuration/domain/entities/user_settings_entity.dart';
import 'package:cashify/features/transaction/domain/usecases/billing_period_usecases.dart';
import 'package:flutter/material.dart';

class BillingPeriodProvider extends ChangeNotifier {
  final BillingPeriodUsecases usecases;

  List<String> _periods = [];
  String? _selectedPeriodId;
  bool _isLoading = false;

  BillingPeriodProvider({required this.usecases});

  List<String> get periods => _periods;
  String? get selectedPeriodId => _selectedPeriodId;
  bool get isLoading => _isLoading;

  String getCurrentBillingPeriodId(UserSettingsEntity settings) {
    final now = DateTime.now();
    if (now.day >= settings.startDay && settings.startDay > 1) {
      final nextMonthDate = DateTime(now.year, now.month + 1);
      return _getBillingPeriodIdFromMonthYear(nextMonthDate);
    }
    return _getBillingPeriodIdFromMonthYear(now);
  }

  DateTimeRange getRangeFromId(String periodId, int startDay) {
    final parts = periodId.split('_');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);

    final end = DateTime(year, month, startDay - 1);
    final start = DateTime(year, month - 1, startDay);

    return DateTimeRange(start: start, end: end);
  }

  String _getBillingPeriodIdFromMonthYear(DateTime date) {
    return "${date.year}_${date.month}";
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
    _selectedPeriodId = periodId;
    notifyListeners();
  }

  Future<void> loadPeriods() async {
    _isLoading = true;
    notifyListeners();

    try {
      _periods = await usecases.fetchAll();
    } catch (e) {
      _periods = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String getIdFromDate(DateTime date, int startDay) {
    if (date.day >= startDay && startDay > 1) {
      final nextMonthDate = DateTime(date.year, date.month + 1);
      return _getBillingPeriodIdFromMonthYear(nextMonthDate);
    }
    return _getBillingPeriodIdFromMonthYear(date);
  }
}
