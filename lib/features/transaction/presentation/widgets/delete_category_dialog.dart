import 'package:cashify/core/theme/app_colors.dart';
import 'package:cashify/features/transaction/domain/entities/category_entity.dart';
import 'package:cashify/features/transaction/presentation/providers/category_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeleteCategoryDialog extends StatefulWidget {
  final CategoryEntity categoryToDelete;
  final List<CategoryEntity> availableCategories;
  final bool onlyMigrate;

  const DeleteCategoryDialog({
    super.key,
    required this.categoryToDelete,
    required this.availableCategories,
    this.onlyMigrate = false,
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
          Icon(
            widget.onlyMigrate
                ? Icons.sync_alt_rounded
                : Icons.warning_amber_rounded,
            color: widget.onlyMigrate ? AppColors.warning : AppColors.warning,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.onlyMigrate ? 'Migrar movimientos' : 'Categoría en uso',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                height: 1.4,
              ),
              children: [
                const TextSpan(text: 'Se moverán los movimientos de '),
                TextSpan(
                  text: '"${widget.categoryToDelete.name}"',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextSpan(
                  text: widget.onlyMigrate
                      ? ' a otra categoría.'
                      : ' a una nueva categoría antes de eliminarla definitivamente.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          InputDecorator(
            decoration: InputDecoration(
              labelText: 'Categoría destino',
              labelStyle: const TextStyle(
                fontSize: 13,
                color: AppColors.textLight,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 4,
              ),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            child: DropdownButton<CategoryEntity>(
              value: _selectedTarget,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              hint: const Text(
                'Seleccionar categoría',
                style: TextStyle(fontSize: 14, color: AppColors.textFaded),
              ),
              items: others
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(
                        c.name,
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
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
        const SizedBox(width: 8),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: widget.onlyMigrate
                ? AppColors.warning
                : AppColors.danger,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: (_selectedTarget == null || _isMigrating)
              ? null
              : () => _migrate(context),
          child: _isMigrating
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.surface,
                  ),
                )
              : Text(
                  widget.onlyMigrate ? 'Migrar ahora' : 'Migrar y eliminar',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }

  Future<void> _migrate(BuildContext context) async {
    if (_selectedTarget == null) return;
    setState(() => _isMigrating = true);

    final provider = context.read<CategoryProvider>();
    final bool success;

    if (widget.onlyMigrate) {
      success = await provider.migrateMovements(
        fromCategoryId: widget.categoryToDelete.id,
        toCategoryId: _selectedTarget!.id,
      );
    } else {
      success = await provider.migrateAndDelete(
        fromCategoryId: widget.categoryToDelete.id,
        toCategoryId: _selectedTarget!.id,
      );
    }

    if (!context.mounted) return;
    Navigator.pop(context, success);
  }
}
