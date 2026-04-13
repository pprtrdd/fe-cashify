import 'package:cashify/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

extension UIHelpers on BuildContext {
  void showErrorSnackBar(String message) {
    final messenger = ScaffoldMessenger.of(this);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: GestureDetector(
          onTap: () => messenger.hideCurrentSnackBar(),
          behavior: HitTestBehavior.opaque,
          child: Row(
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
        ),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void showSuccessSnackBar(String message) {
    final messenger = ScaffoldMessenger.of(this);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: GestureDetector(
          onTap: () => messenger.hideCurrentSnackBar(),
          behavior: HitTestBehavior.opaque,
          child: Row(
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
        ),
        backgroundColor: AppColors.income,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
