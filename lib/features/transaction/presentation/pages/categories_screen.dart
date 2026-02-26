import 'package:cashify/core/theme/app_colors.dart';
import 'package:cashify/core/widgets/primary_app_bar.dart';
import 'package:cashify/features/transaction/domain/entities/category_entity.dart';
import 'package:cashify/features/transaction/presentation/components/category_dialogs.dart';
import 'package:cashify/features/transaction/presentation/providers/category_provider.dart';
import 'package:cashify/features/transaction/presentation/providers/movement_provider.dart';
import 'package:cashify/features/transaction/presentation/widgets/category_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PrimaryAppBar(
        title: 'Categorías',
        showAddButton: true,
        onAddPressed: () => _showAddSheet(context),
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (provider.categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 64,
                    color: AppColors.iconLight.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Sin categorías',
                    style: TextStyle(color: AppColors.textLight, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tocá + para agregar una',
                    style: TextStyle(color: AppColors.textFaded, fontSize: 13),
                  ),
                ],
              ),
            );
          }

          final planned = provider.categories.where((c) => !c.isExtra).toList();
          final unforeseen = provider.categories
              .where((c) => c.isExtra)
              .toList();

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              if (planned.isNotEmpty) ...[
                _SectionHeader(
                  label: 'Planificados',
                  color: AppColors.iconPrimary,
                  icon: Icons.calendar_today_rounded,
                ),
                ...planned.map(
                  (c) => _CategoryTile(
                    category: c,
                    onTap: () => _onCategoryTap(context, c, provider),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              if (unforeseen.isNotEmpty) ...[
                _SectionHeader(
                  label: 'Imprevistos',
                  color: AppColors.iconWarning,
                  icon: Icons.flash_on_rounded,
                ),
                ...unforeseen.map(
                  (c) => _CategoryTile(
                    category: c,
                    onTap: () => _onCategoryTap(context, c, provider),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _onCategoryTap(
    BuildContext context,
    CategoryEntity category,
    CategoryProvider provider,
  ) async {
    final result = await CategoryDialogs.showDetail(
      context: context,
      category: category,
      provider: provider,
    );

    if (!context.mounted) return;

    if (result == 'edit') {
      _showAddSheet(context, categoryToEdit: category);
    } else if (result == 'delete' || result == 'delete_success') {
      if (result == 'delete') {
        _onDelete(context, category, provider);
      } else {
        _showSnack(context, 'Categoría eliminada', true);
      }
    }
  }

  Future<void> _onDelete(
    BuildContext context,
    CategoryEntity category,
    CategoryProvider provider,
  ) async {
    final success = await CategoryDialogs.showDeleteConfirmation(
      context: context,
      category: category,
      provider: provider,
    );

    if (success == true && context.mounted) {
      context.read<MovementProvider>().refreshData();
      _showSnack(context, 'Categoría gestionada correctamente', true);
    }
  }

  void _showSnack(BuildContext context, String message, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? AppColors.success : AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showAddSheet(BuildContext context, {CategoryEntity? categoryToEdit}) {
    CategoryBottomSheet.show(context, categoryToEdit: categoryToEdit);
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _SectionHeader({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Row(
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final CategoryEntity category;
  final VoidCallback onTap;

  const _CategoryTile({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isExpense = category.isExpense;
    final color = isExpense ? AppColors.iconExpense : AppColors.iconIncome;

    final isArchived = category.isArchived;

    Widget content = ListTile(
      contentPadding: const EdgeInsets.only(left: 16, right: 8),
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: color.withValues(alpha: 0.12),
        child: Icon(
          isExpense ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
          size: 16,
          color: color,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              category.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (isArchived)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Text(
                'ARCHIVADA',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textFaded,
                  letterSpacing: 0.5,
                ),
              ),
            ),
        ],
      ),
      subtitle: Text(
        category.isExpense ? 'GASTO' : 'INGRESO',
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      onTap: onTap,
    );

    if (isArchived) {
      content = ColorFiltered(
        colorFilter: const ColorFilter.matrix([
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]),
        child: Opacity(opacity: 0.6, child: content),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: content,
    );
  }
}
