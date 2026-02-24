import 'package:cashify/core/theme/app_colors.dart';
import 'package:cashify/features/transaction/domain/entities/category_entity.dart';
import 'package:cashify/features/transaction/presentation/providers/category_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MigrateMovementsDialog extends StatefulWidget {
  final CategoryEntity sourceCategory;
  final List<CategoryEntity> availableCategories;

  const MigrateMovementsDialog({
    super.key,
    required this.sourceCategory,
    required this.availableCategories,
  });

  @override
  State<MigrateMovementsDialog> createState() => _MigrateMovementsDialogState();
}

class _MigrateMovementsDialogState extends State<MigrateMovementsDialog> {
  CategoryEntity? _selectedTarget;
  bool _isMigrating = false;

  @override
  Widget build(BuildContext context) {
    final others = widget.availableCategories
        .where((c) => c.id != widget.sourceCategory.id)
        .toList();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.sync_alt_rounded, color: AppColors.warning),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Migrar movimientos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  text: '"${widget.sourceCategory.name}"',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const TextSpan(text: ' a otra categoría.'),
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
            backgroundColor: AppColors.warning,
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
              : const Text(
                  'Migrar ahora',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }

  Future<void> _migrate(BuildContext context) async {
    if (_selectedTarget == null) return;
    setState(() => _isMigrating = true);

    final provider = context.read<CategoryProvider>();
    final bool success = await provider.migrateMovements(
      fromCategoryId: widget.sourceCategory.id,
      toCategoryId: _selectedTarget!.id,
    );

    if (!context.mounted) return;
    Navigator.pop(context, success);
  }
}
