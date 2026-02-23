import 'package:cashify/core/theme/app_colors.dart';
import 'package:cashify/features/transaction/domain/entities/category_entity.dart';
import 'package:cashify/features/transaction/presentation/providers/category_provider.dart';
import 'package:cashify/features/transaction/presentation/providers/movement_provider.dart';
import 'package:cashify/features/transaction/presentation/widgets/delete_category_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoryDialogs {
  static Future<dynamic> showDetail({
    required BuildContext context,
    required CategoryEntity category,
    required CategoryProvider provider,
  }) {
    return showDialog(
      context: context,
      builder: (_) =>
          _CategoryDetailDialog(category: category, provider: provider),
    );
  }

  static Future<bool?> showDeleteConfirmation({
    required BuildContext context,
    required CategoryEntity category,
    required CategoryProvider provider,
  }) async {
    final hasMovements = await provider.hasMovements(category.id);

    if (!context.mounted) return false;

    if (!hasMovements) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            '¿Eliminar categoría?',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          content: RichText(
            text: TextSpan(
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              children: [
                const TextSpan(text: 'Se eliminará la categoría '),
                TextSpan(
                  text: '"${category.name}"',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const TextSpan(text: '. Esta acción no se puede deshacer.'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
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
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar'),
            ),
          ],
        ),
      );

      if (confirmed == true && context.mounted) {
        return await provider.deleteCategory(category.id);
      }
      return confirmed;
    } else {
      return await showDialog<bool>(
        context: context,
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
          child: DeleteCategoryDialog(
            categoryToDelete: category,
            availableCategories: provider.categories,
          ),
        ),
      );
    }
  }
}

class _CategoryDetailDialog extends StatelessWidget {
  final CategoryEntity category;
  final CategoryProvider provider;

  const _CategoryDetailDialog({required this.category, required this.provider});

  @override
  Widget build(BuildContext context) {
    final isExpense = category.isExpense;
    final color = isExpense ? AppColors.expense : AppColors.income;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: color.withValues(alpha: 0.1),
                  child: Icon(
                    isExpense
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    color: color,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  category.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    (isExpense ? 'GASTO' : 'INGRESO') +
                        (category.isExtra ? ' • IMPREVISTO' : ' • PLANIFICADO'),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: color,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _DetailRow(
              icon: Icons.calendar_today_rounded,
              label: "Tipo de presupuesto",
              value: category.isExtra
                  ? "Imprevisto / Variable"
                  : "Planificado / Fijo",
            ),
            const Divider(height: 32, color: AppColors.background),
            _DetailRow(
              icon: Icons.history_rounded,
              label: "Fecha de creación",
              value:
                  category.createdAt.day.toString().padLeft(2, '0') +
                  '/' +
                  category.createdAt.month.toString().padLeft(2, '0') +
                  '/' +
                  category.createdAt.year.toString(),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionButton(
                  icon: Icons.edit_rounded,
                  label: "Editar",
                  onTap: () => Navigator.pop(context, 'edit'),
                ),
                _ActionButton(
                  icon: Icons.sync_alt_rounded,
                  label: "Migrar",
                  color: AppColors.warning,
                  onTap: () => _onMigrate(context),
                ),
                _ActionButton(
                  icon: category.isArchived
                      ? Icons.unarchive_outlined
                      : Icons.archive_outlined,
                  label: category.isArchived ? "Desarchivar" : "Archivar",
                  color: AppColors.textLight,
                  onTap: () => _onArchive(context),
                ),
                _ActionButton(
                  icon: Icons.delete_outline_rounded,
                  label: "Eliminar",
                  color: AppColors.expense,
                  onTap: () => _onDelete(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cerrar",
                style: TextStyle(color: AppColors.textFaded),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onMigrate(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: provider,
        child: DeleteCategoryDialog(
          categoryToDelete: category,
          availableCategories: provider.categories,
          onlyMigrate: true,
        ),
      ),
    );

    if (result == true && context.mounted) {
      context.read<MovementProvider>().refreshData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Movimientos migrados correctamente'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _onArchive(BuildContext context) async {
    final isArchiving = !category.isArchived;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isArchiving ? '¿Archivar categoría?' : '¿Desarchivar categoría?',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        content: Text(
          isArchiving
              ? 'La categoría "${category.name}" ya no aparecerá al agregar nuevos movimientos, pero se mantendrá en los anteriores.'
              : 'La categoría "${category.name}" volverá a aparecer al agregar nuevos movimientos.',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textLight),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.textPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(isArchiving ? 'Archivar' : 'Desarchivar'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await provider.archiveCategory(
        category.id,
        isArchived: isArchiving,
      );
      if (success && context.mounted) {
        context.read<MovementProvider>().refreshData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isArchiving
                  ? 'Categoría archivada correctamente'
                  : 'Categoría desarchivada correctamente',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, 'archive_success');
      }
    }
  }

  Future<void> _onDelete(BuildContext context) async {
    final success = await CategoryDialogs.showDeleteConfirmation(
      context: context,
      category: category,
      provider: provider,
    );

    if (success == true && context.mounted) {
      context.read<MovementProvider>().refreshData();
      Navigator.pop(context, 'delete_success');
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textLight),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textLight,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: effectiveColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: effectiveColor, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: effectiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
