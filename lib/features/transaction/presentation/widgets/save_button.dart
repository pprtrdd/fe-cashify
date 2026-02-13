import 'package:cashify/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class SaveButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  final Color color;
  final String label;

  const SaveButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    this.color = AppColors.primary,
    this.label = "GUARDAR MOVIMIENTO",
  });

  @override
  Widget build(BuildContext context) {
    const Color contentColor = AppColors.textOnPrimary;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(scale: animation, child: child),
      ),
      child: isLoading
          ? SizedBox(
              key: const ValueKey('loading-state'),
              height: 56,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            )
          : Container(
              key: const ValueKey('button-state'),
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: onPressed,
                icon: const Icon(
                  Icons.save_rounded,
                  size: 20,
                  color: contentColor,
                ),
                label: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    fontSize: 15,
                    color: contentColor,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: contentColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shadowColor: AppColors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
    );
  }
}
