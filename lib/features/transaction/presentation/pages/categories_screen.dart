import 'package:cashify/core/theme/app_colors.dart';
import 'package:cashify/features/transaction/domain/entities/category_entity.dart';
import 'package:cashify/features/transaction/presentation/providers/category_provider.dart';
import 'package:cashify/features/transaction/presentation/providers/movement_provider.dart';
import 'package:cashify/features/transaction/presentation/widgets/delete_category_dialog.dart';
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
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        title: const Text(
          'Categorías',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Nueva categoría',
            onPressed: () => _showAddSheet(context),
          ),
        ],
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
                    color: AppColors.textLight.withValues(alpha: 0.4),
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
                  color: AppColors.primary,
                  icon: Icons.calendar_today_rounded,
                ),
                ...planned.map(
                  (c) => _CategoryTile(
                    category: c,
                    onTap: () => _showAddSheet(context, categoryToEdit: c),
                    onDelete: () => _onDelete(context, c, provider),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              if (unforeseen.isNotEmpty) ...[
                _SectionHeader(
                  label: 'Imprevistos',
                  color: AppColors.warning,
                  icon: Icons.flash_on_rounded,
                ),
                ...unforeseen.map(
                  (c) => _CategoryTile(
                    category: c,
                    onTap: () => _showAddSheet(context, categoryToEdit: c),
                    onDelete: () => _onDelete(context, c, provider),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _onDelete(
    BuildContext context,
    CategoryEntity category,
    CategoryProvider provider,
  ) async {
    final hasMovements = await provider.hasMovements(category.id);

    if (!context.mounted) return;

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
        final success = await provider.deleteCategory(category.id);
        if (context.mounted) {
          if (success) {
            context.read<MovementProvider>().refreshData();
          }
          _showSnack(
            context,
            success ? 'Categoría eliminada' : 'Error al eliminar la categoría',
            success,
          );
        }
      }
    } else {
      final result = await showDialog<bool>(
        context: context,
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
          child: DeleteCategoryDialog(
            categoryToDelete: category,
            availableCategories: provider.categories,
          ),
        ),
      );

      if (result == true && context.mounted) {
        context.read<MovementProvider>().refreshData();
        _showSnack(context, 'Movimientos migrados y categoría eliminada', true);
      }
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<CategoryProvider>(),
        child: _AddCategorySheet(categoryToEdit: categoryToEdit),
      ),
    );
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
  final VoidCallback onDelete;

  const _CategoryTile({
    required this.category,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = category.isExpense;
    final color = isExpense ? AppColors.expense : AppColors.income;

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
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 16, right: 8),
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(
            isExpense
                ? Icons.arrow_upward_rounded
                : Icons.arrow_downward_rounded,
            size: 16,
            color: color,
          ),
        ),
        title: Text(
          category.name,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              color: AppColors.textLight,
              tooltip: 'Editar',
              onPressed: onTap,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              color: AppColors.danger,
              tooltip: 'Eliminar',
              onPressed: onDelete,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddCategorySheet extends StatefulWidget {
  final CategoryEntity? categoryToEdit;

  const _AddCategorySheet({this.categoryToEdit});

  @override
  State<_AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<_AddCategorySheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;

  late bool _isExpense;
  late bool _isExtra;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final category = widget.categoryToEdit;
    _nameController = TextEditingController(text: category?.name ?? '');
    _isExpense = category?.isExpense ?? true;
    _isExtra = category?.isExtra ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final isEditing = widget.categoryToEdit != null;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomPadding),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isEditing ? 'Editar categoría' : 'Nueva categoría',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.sentences,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Nombre',
                labelStyle: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textLight,
                ),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Ingresá un nombre';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                const Text(
                  'Tipo:',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(
                        value: true,
                        label: Text('Gasto'),
                        icon: Icon(Icons.arrow_upward_rounded, size: 16),
                      ),
                      ButtonSegment(
                        value: false,
                        label: Text('Ingreso'),
                        icon: Icon(Icons.arrow_downward_rounded, size: 16),
                      ),
                    ],
                    selected: {_isExpense},
                    onSelectionChanged: (sel) =>
                        setState(() => _isExpense = sel.first),
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith((
                        states,
                      ) {
                        if (states.contains(WidgetState.selected)) {
                          return _isExpense
                              ? AppColors.expense
                              : AppColors.income;
                        }
                        return AppColors.background;
                      }),
                      foregroundColor: WidgetStateProperty.resolveWith((
                        states,
                      ) {
                        if (states.contains(WidgetState.selected)) {
                          return AppColors.background;
                        }
                        return AppColors.textLight;
                      }),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                title: const Text(
                  'Es extra',
                  style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
                ),
                subtitle: const Text(
                  'Gastos/ingresos fuera del plan habitual',
                  style: TextStyle(fontSize: 11, color: AppColors.textFaded),
                ),
                value: _isExtra,
                activeThumbColor: AppColors.primary,
                onChanged: (val) => setState(() => _isExtra = val),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isSaving ? null : () => _save(context),
                child: _isSaving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.background,
                          strokeCap: StrokeCap.round,
                        ),
                      )
                    : Text(
                        isEditing ? 'Guardar cambios' : 'Guardar',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final provider = context.read<CategoryProvider>();
    final isEditing = widget.categoryToEdit != null;
    final name = _nameController.text.trim();

    final bool success;
    if (isEditing) {
      success = await provider.updateCategory(
        category: widget.categoryToEdit!,
        name: name,
        isExpense: _isExpense,
        isExtra: _isExtra,
      );
    } else {
      success = await provider.addCategory(
        name: name,
        isExpense: _isExpense,
        isExtra: _isExtra,
      );
    }

    if (!context.mounted) return;
    if (success) {
      context.read<MovementProvider>().refreshData();
      Navigator.pop(context);
    } else {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Error al actualizar la categoría'
                : 'Error al guardar la categoría',
          ),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }
}
