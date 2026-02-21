import 'package:cashify/core/theme/app_colors.dart';
import 'package:cashify/features/transaction/domain/entities/category_entity.dart';
import 'package:cashify/features/transaction/presentation/providers/category_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeleteCategoryDialog extends StatefulWidget {
  final CategoryEntity categoryToDelete;
  final List<CategoryEntity> availableCategories;

  const DeleteCategoryDialog({
    super.key,
    required this.categoryToDelete,
    required this.availableCategories,
  });

  @override
  State<DeleteCategoryDialog> createState() => _DeleteCategoryDialogState();
}

class _DeleteCategoryDialogState extends State<DeleteCategoryDialog> {
  CategoryEntity? _selectedTarget;
  bool _isMigrating = false;

  @override
  Widget build(BuildContext context) {
    final others = widget.availableCategories
        .where((c) => c.id != widget.categoryToDelete.id)
        .toList();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Categoría en uso',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              children: [
                const TextSpan(text: 'La categoría '),
                TextSpan(
                  text: '"${widget.categoryToDelete.name}"',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const TextSpan(
                  text:
                      ' tiene movimientos asociados. Seleccioná una categoría destino para migrarlos antes de eliminarla.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          InputDecorator(
            decoration: InputDecoration(
              labelText: 'Mover movimientos a...',
              labelStyle: const TextStyle(
                fontSize: 13,
                color: AppColors.textLight,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            child: DropdownButton<CategoryEntity>(
              value: _selectedTarget,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              hint: const Text(
                'Seleccionar categoría',
                style: TextStyle(fontSize: 13, color: AppColors.textFaded),
              ),
              items: others
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(c.name, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: (val) => setState(() => _selectedTarget = val),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isMigrating ? null : () => Navigator.pop(context, false),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: AppColors.textLight),
          ),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.danger,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: (_selectedTarget == null || _isMigrating)
              ? null
              : () => _migrate(context),
          child: _isMigrating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.background,
                  ),
                )
              : const Text('Migrar y eliminar'),
        ),
      ],
    );
  }

  Future<void> _migrate(BuildContext context) async {
    if (_selectedTarget == null) return;
    setState(() => _isMigrating = true);

    final provider = context.read<CategoryProvider>();
    final success = await provider.migrateAndDelete(
      fromCategoryId: widget.categoryToDelete.id,
      toCategoryId: _selectedTarget!.id,
    );

    if (!context.mounted) return;
    Navigator.pop(context, success);
  }
}
