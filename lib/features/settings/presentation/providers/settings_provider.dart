import 'package:cashify/features/settings/domain/entities/user_settings_entity.dart';
import 'package:cashify/features/settings/domain/usecases/settings_usecases.dart';
import 'package:flutter/foundation.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsUsecases settingsUsecases;
  UserSettingsEntity _settings = UserSettingsEntity.empty();
  bool _isLoading = false;

  SettingsProvider({required this.settingsUsecases});

  UserSettingsEntity get settings => _settings;
  bool get isLoading => _isLoading;

  Future<void> loadSettings() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      _settings = await settingsUsecases.get();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSettings(UserSettingsEntity newSettings) async {
    if (_settings == newSettings) return;

    await settingsUsecases.save(newSettings);

    _settings = newSettings;
    notifyListeners();
  }
}
