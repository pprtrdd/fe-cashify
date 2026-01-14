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
  int get currentAccountingYear {
    final now = DateTime.now();
    if (_settings.billingPeriodType == 'month_to_month' ||
        now.day < _settings.startDay) {
      return now.year;
    }
    return DateTime(now.year, now.month + 1).year;
  }

  int get currentAccountingMonth {
    final now = DateTime.now();

    /* Obtenemos el último día real del mes actual
       DateTime(año, mes + 1, 0) nos da el último día del mes actual. */
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;

    /* Si el startDay configurado es mayor al último día del mes (ej: 31 en febrero)
       usamos el último día disponible (28 o 29). */
    int effectiveStartDay = _settings.startDay > lastDayOfMonth
        ? lastDayOfMonth
        : _settings.startDay;

    if (_settings.billingPeriodType == 'month_to_month' ||
        now.day < effectiveStartDay) {
      return now.month;
    }
    return DateTime(now.year, now.month + 1).month;
  }

  String get currentPeriodRangeText {
    final now = DateTime.now();
    if (_settings.billingPeriodType == 'month_to_month') {
      return "Mes de ${_getMonthName(now.month)}";
    }

    if (now.day >= _settings.startDay) {
      return "${_settings.startDay} ${_getMonthName(now.month)} - ${_settings.endDay} ${_getMonthName(now.month + 1)}";
    } else {
      return "${_settings.startDay} ${_getMonthName(now.month - 1)} - ${_settings.endDay} ${_getMonthName(now.month)}";
    }
  }

  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      _settings = await settingsUsecases.get();
    } catch (e) {
      debugPrint("Error al cargar configuración: $e");
      _settings = UserSettingsEntity.empty();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSettings(UserSettingsEntity newSettings) async {
    try {
      await settingsUsecases.save(newSettings);
      _settings = newSettings;
      notifyListeners();
    } catch (e) {
      debugPrint("Error al guardar configuración: $e");
      rethrow;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    int index = (month - 1) % 12;
    if (index < 0) index += 12;
    return months[index];
  }
}
