import 'package:cashify/features/auth/presentation/login_screen.dart';
import 'package:cashify/features/transaction/presentation/pages/dashboard_screen.dart';
import 'package:cashify/features/user_config/presentation/providers/user_config_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<UserConfigProvider>();

    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text("Configurando tu cuenta..."),
            ],
          ),
        ),
      );
    }

    if (authProvider.isAuthenticated) {
      return const DashboardScreen();
    }

    return const LoginScreen();
  }
}
