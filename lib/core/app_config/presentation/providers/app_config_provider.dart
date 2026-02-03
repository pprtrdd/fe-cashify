import 'package:cashify/core/app_config/domain/entities/app_config_entity.dart';
import 'package:cashify/core/app_config/domain/usecases/app_config_usecases.dart';
import 'package:flutter/material.dart';

class AppConfigProvider extends ChangeNotifier {
  final AppConfigUsecases appConfigUsecases;
  AppConfigEntity _appConfig = AppConfigEntity.empty();
  bool _isLoading = false;

  AppConfigProvider({required this.appConfigUsecases});

  AppConfigEntity get appConfig => _appConfig;
  bool get isLoading => _isLoading;

  Future<void> loadAppConfig() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      _appConfig = await appConfigUsecases.get();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
