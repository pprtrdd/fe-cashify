import 'package:cashify/features/configuration/domain/entities/user_settings_entity.dart';
import 'package:cashify/features/configuration/domain/usecases/settings_usecases.dart';
import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsUsecases settingsUsecases;

  UserSettingsEntity _settings = UserSettingsEntity.empty();
  bool _isLoading = false;

  SettingsProvider({required this.settingsUsecases});

  UserSettingsEntity get settings => _settings;
  bool get isLoading => _isLoading;
  String get currentBillingPeriodId {
    final now = DateTime.now();
    if (now.day >= _settings.startDay && _settings.startDay > 1) {
      final nextMonthDate = DateTime(now.year, now.month + 1);
      return getBillingPeriodIdFromMonthYear(nextMonthDate);
    }
    return getBillingPeriodIdFromMonthYear(now);
  }

  DateTimeRange get currentBillingPeriodRange {
    return _settings.getDateTimeRangeFromBillingPeriod(currentBillingPeriodId);
  }

  String getBillingPeriodIdFromMonthYear(DateTime date) {
    return "${date.year}_${date.month}";
  }

  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();
    try {
      _settings = await settingsUsecases.get();
    } catch (e) {
      _settings = UserSettingsEntity.empty();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSettings(UserSettingsEntity newSettings) async {
    await settingsUsecases.save(newSettings);
    _settings = newSettings;
    notifyListeners();
  }
}
