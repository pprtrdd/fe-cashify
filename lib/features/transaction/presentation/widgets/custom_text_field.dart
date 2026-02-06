import 'package:cashify/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final Color accentColor;
  final bool isRequired;
  final bool isNumeric;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.accentColor = AppColors.primary,
    this.isRequired = true,
    this.isNumeric = false,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 25,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: isNumeric
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          readOnly: readOnly,
          onTap: onTap,
          maxLines: maxLines,
          style: const TextStyle(color: AppColors.textPrimary),
          validator: (value) {
            if (!isRequired && (value == null || value.isEmpty)) return null;
            if (isRequired && (value == null || value.isEmpty)) {
              return "Campo requerido";
            }
            if (isNumeric && value != null && value.isNotEmpty) {
              if (double.tryParse(value.replaceAll(',', '.')) == null) {
                return "Número inválido";
              }
            }
            return validator?.call(value);
          },
          decoration: InputDecoration(
            labelText: isRequired ? label : "$label (Opcional)",
            labelStyle: TextStyle(color: AppColors.textLight),
            prefixIcon: Icon(icon, color: AppColors.primary),
            filled: false,
            helperText: ' ',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
