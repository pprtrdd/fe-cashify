import 'package:cashify/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../providers/movement_provider.dart';

class CategoryDropdownField extends StatelessWidget {
  final String? value;
  final MovementProvider provider;
  final ValueChanged<String?> onChanged;

  const CategoryDropdownField({
    super.key,
    required this.value,
    required this.provider,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: provider.isLoading ? "Cargando..." : "Categoría",
        prefixIcon: provider.isLoading
            ? const UnconstrainedBox(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
              )
            : const Icon(Icons.category_outlined, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.border),
        ),
        filled: true,
        fillColor: AppColors.fieldFill,
      ),
      items: provider.categories.map((cat) {
        final bool isExpense = cat.isExpense;
        final Color iconColor = isExpense
            ? AppColors.expense
            : AppColors.income;

        return DropdownMenuItem<String>(
          value: cat.id,
          child: Row(
            children: [
              Icon(
                isExpense
                    ? Icons.remove_circle_outline
                    : Icons.add_circle_outline,
                color: iconColor,
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(
                cat.name,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? "Selecciona una categoría" : null,
      dropdownColor: AppColors.surface,
      iconEnabledColor: AppColors.primary,
    );
  }
}
