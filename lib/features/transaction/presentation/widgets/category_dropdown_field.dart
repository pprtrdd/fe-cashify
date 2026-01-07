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
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : const Icon(Icons.category_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: provider.categories.map((cat) {
        return DropdownMenuItem<String>(
          value: cat.id,
          child: Row(
            children: [
              Icon(
                cat.isExpense
                    ? Icons.remove_circle_outline
                    : Icons.add_circle_outline,
                color: cat.isExpense ? Colors.red : Colors.green,
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(cat.name),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? "Selecciona una categoría" : null,
    );
  }
}
