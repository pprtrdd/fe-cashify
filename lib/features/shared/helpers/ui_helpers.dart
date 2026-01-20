import 'package:cashify/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

extension UIHelpers on BuildContext {
  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).clearSnackBars(); // Limpia snacks previos
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.textOnPrimary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.danger, // Tu nuevo color de alto contraste
        behavior: SnackBarBehavior.floating, // Se ve más moderno
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).clearSnackBars();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              color: AppColors.textOnPrimary,
            ),
            const SizedBox(width: 12),
            Text(
              message,
              style: const TextStyle(color: AppColors.textOnPrimary),
            ),
          ],
        ),
        backgroundColor: AppColors.income, // Tu color azul de alto contraste
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
