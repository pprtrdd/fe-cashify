import 'package:cashify/features/user_config/presentation/providers/user_config_provider.dart';
import 'package:cashify/core/theme/app_colors.dart';
import 'package:cashify/features/shared/helpers/ui_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> _handleLogin(
    BuildContext context,
    UserConfigProvider provider,
  ) async {
    try {
      await provider.signInWithGoogle();
    } catch (e) {
      if (!context.mounted) return;
      context.showErrorSnackBar("Error al iniciar sesión: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<UserConfigProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _AppLogo(),
            const SizedBox(height: 40),
            _LoginButton(
              isLoading: authProvider.isLoading,
              onPressed: () => _handleLogin(context, authProvider),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppLogo extends StatelessWidget {
  const _AppLogo();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Icon(
          Icons.account_balance_wallet,
          size: 80,
          color: AppColors.iconPrimary,
        ),
        SizedBox(height: 20),
        Text(
          "Cashify",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _LoginButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _LoginButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const CircularProgressIndicator(color: AppColors.primary);
    }

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      icon: const Icon(Icons.login),
      label: const Text("Entrar con Google"),
      onPressed: onPressed,
    );
  }
}
