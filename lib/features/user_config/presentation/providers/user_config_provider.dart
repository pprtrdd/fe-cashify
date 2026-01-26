import 'package:cashify/core/auth/auth_service.dart';
import 'package:cashify/features/user_config/domain/usecases/user_config_usecases.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserConfigProvider extends ChangeNotifier {
  final AuthService _authService;
  final UserConfigUsecases _userConfigUsecases;

  User? _user;
  bool _isLoading = false;

  UserConfigProvider({
    required AuthService authService,
    required UserConfigUsecases userConfigUsecases,
  }) : _authService = authService,
       _userConfigUsecases = userConfigUsecases {
    _authService.userStatus.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  Future<void> signInWithGoogle() async {
    _setLoading(true);

    try {
      final credential = await _authService.signInWithGoogle();
      final user = credential.user;

      if (user != null) {
        await _userConfigUsecases.initializeUserDataIfNew(user.uid);
      }
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
