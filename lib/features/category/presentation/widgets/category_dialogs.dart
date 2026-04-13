import 'package:cashify/core/theme/app_colors.dart';
import 'package:cashify/features/shared/widgets/detail_row.dart';
import 'package:cashify/features/shared/widgets/item_detail_dialog.dart';
import 'package:cashify/features/category/domain/entities/category_entity.dart';
import 'package:cashify/features/category/presentation/providers/category_provider.dart';
import 'package:cashify/features/transaction/presentation/providers/transaction_provider.dart';
import 'package:cashify/features/category/presentation/widgets/delete_category_dialog.dart';
import 'package:cashify/features/category/presentation/widgets/migrate_transactions_dialog.dart';
import 'package:cashify/features/shared/helpers/ui_helper.dart';
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
    final hasTransactions = await provider.hasTransactions(category.id);

    if (!context.mounted) return false;

    if (!hasTransactions) {
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

    return ItemDetailDialog(
      header: DialogHeader(
        icon: isExpense
            ? Icons.arrow_upward_rounded
            : Icons.arrow_downward_rounded,
        color: color,
        title: category.name,
        badgeText:
            (isExpense ? 'GASTO' : 'INGRESO') +
            (category.isExtra ? ' • IMPREVISTO' : ' • PLANIFICADO'),
      ),
      detailSections: [
        DetailRow(
          icon: Icons.calendar_today_rounded,
          label: "Tipo de presupuesto",
          value: category.isExtra
              ? "Imprevisto / Variable"
              : "Planificado / Fijo",
        ),
        const Divider(height: 32, color: AppColors.background),
        DetailRow(
          icon: Icons.history_rounded,
          label: "Fecha de creación",
          value:
              '${category.createdAt.day.toString().padLeft(2, '0')}/${category.createdAt.month.toString().padLeft(2, '0')}/${category.createdAt.year}',
        ),
      ],
      actions: [
        DialogAction(
          icon: Icons.edit_rounded,
          label: "Editar",
          onTap: () => Navigator.pop(context, 'edit'),
        ),
        DialogAction(
          icon: Icons.sync_alt_rounded,
          label: "Migrar",
          color: AppColors.warning,
          onTap: () => _onMigrate(context),
        ),
        DialogAction(
          icon: category.isArchived
              ? Icons.unarchive_outlined
              : Icons.archive_outlined,
          label: category.isArchived ? "Desarchivar" : "Archivar",
          color: AppColors.textLight,
          onTap: () => _onArchive(context),
        ),
        DialogAction(
          icon: Icons.delete_outline_rounded,
          label: "Eliminar",
          color: AppColors.expense,
          onTap: () => _onDelete(context),
        ),
      ],
    );
  }

  Future<void> _onMigrate(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: provider,
        child: MigrateTransactionsDialog(
          sourceCategory: category,
          availableCategories: provider.categories,
        ),
      ),
    );

    if (result == true && context.mounted) {
      context.read<TransactionProvider>().refreshData();
      context.showSuccessSnackBar('Movimientos migrados correctamente');
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
        context.read<TransactionProvider>().refreshData();
        context.showSuccessSnackBar(
          isArchiving
              ? 'Categoría archivada correctamente'
              : 'Categoría desarchivada correctamente',
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
      context.read<TransactionProvider>().refreshData();
      Navigator.pop(context, 'delete_success');
    }
  }
}

