import 'package:cashify/core/app_info/domain/entities/app_info_entity.dart';
import 'package:cashify/core/app_info/domain/usecases/app_info_usecases.dart';
import 'package:flutter/material.dart';

class AppInfoProvider extends ChangeNotifier {
  final AppInfoUsecases appInfoUsecases;
  AppInfoEntity _appInfo = AppInfoEntity.empty();
  bool _isLoading = false;

  AppInfoProvider({required this.appInfoUsecases});

  AppInfoEntity get appInfo => _appInfo;
  bool get isLoading => _isLoading;

  Future<void> loadAppInfo() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      _appInfo = await appInfoUsecases.get();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
