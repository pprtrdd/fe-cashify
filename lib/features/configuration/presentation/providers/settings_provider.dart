import 'package:cashify/features/configuration/domain/entities/user_settings_entity.dart';
import 'package:cashify/features/configuration/domain/usecases/settings_usecases.dart';
import 'package:flutter/foundation.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsUsecases settingsUsecases;
  UserSettingsEntity _settings = UserSettingsEntity.empty();
  bool _isLoading = false;

  SettingsProvider({required this.settingsUsecases});

  UserSettingsEntity get settings => _settings;
  bool get isLoading => _isLoading;

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
