import 'package:cashify/core/theme/app_colors.dart';
import 'package:cashify/features/transaction/domain/entities/category_entity.dart';
import 'package:cashify/features/transaction/presentation/providers/category_provider.dart';
import 'package:cashify/features/transaction/presentation/providers/movement_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoryBottomSheet extends StatefulWidget {
  final CategoryEntity? categoryToEdit;

  const CategoryBottomSheet({super.key, this.categoryToEdit});

  static Future<void> show(
    BuildContext context, {
    CategoryEntity? categoryToEdit,
    CategoryProvider? provider,
  }) {
    final effectiveProvider = provider ?? context.read<CategoryProvider>();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: effectiveProvider,
        child: CategoryBottomSheet(categoryToEdit: categoryToEdit),
      ),
    );
  }

  @override
  State<CategoryBottomSheet> createState() => _CategoryBottomSheetState();
}

class _CategoryBottomSheetState extends State<CategoryBottomSheet> {
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
