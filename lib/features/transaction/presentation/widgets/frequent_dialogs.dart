import 'package:cashify/core/theme/app_colors.dart';
import 'package:cashify/core/utils/formatters.dart';
import 'package:cashify/features/settings/presentation/providers/settings_provider.dart';
import 'package:cashify/features/transaction/domain/entities/frequent_movement_entity.dart';
import 'package:cashify/features/transaction/presentation/components/movement_dialogs.dart';
import 'package:cashify/features/transaction/presentation/pages/frequent_form_screen.dart';
import 'package:cashify/features/transaction/presentation/providers/billing_period_provider.dart';
import 'package:cashify/features/transaction/presentation/providers/frequent_movement_provider.dart';
import 'package:cashify/features/transaction/presentation/providers/movement_provider.dart';
import 'package:cashify/features/transaction/presentation/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FrequentDetailDialog extends StatelessWidget {
  final FrequentMovementEntity frequent;

  const FrequentDetailDialog({super.key, required this.frequent});

  @override
  Widget build(BuildContext context) {
    final movementProv = context.watch<MovementProvider>();
    final isIncome = movementProv.incomeCategoryIds.contains(
      frequent.categoryId,
    );
    final categoryName = movementProv.getCategoryName(frequent.categoryId);
    final color = isIncome ? AppColors.income : AppColors.expense;
    final amountStyle = TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w900,
      color: color,
    );

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
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
                      isIncome
                          ? Icons.arrow_downward
                          : Icons.arrow_upward_rounded,
                      color: color,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    Formatters.currencyWithSymbol(frequent.amount),
                    style: amountStyle,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    frequent.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
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
                      categoryName.toUpperCase(),
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
              DetailRow(
                icon: Icons.repeat,
                label: "Frecuencia",
                value: frequent.frequency.label,
              ),
              const Divider(height: 24, color: AppColors.background),
              DetailRow(
                icon: Icons.calendar_today_rounded,
                label: "Día de Pago",
                value: "Día ${frequent.paymentDay} de cada mes",
              ),
              const Divider(height: 24, color: AppColors.background),
              DetailRow(
                icon: Icons.store_rounded,
                label: "Origen/Lugar",
                value: frequent.source,
              ),
              const Divider(height: 24, color: AppColors.background),
              DetailRow(
                icon: Icons.category_outlined,
                label: "Categoría",
                value: categoryName,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MovementActionButton(
                    icon: Icons.add_circle_outline_rounded,
                    label: "Ingresar",
                    color: AppColors.primary,
                    onTap: () => _showEnterMovementDialog(context),
                  ),
                  MovementActionButton(
                    icon: Icons.edit_rounded,
                    label: "Editar",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              FrequentFormScreen(frequent: frequent),
                        ),
                      );
                    },
                  ),
                  MovementActionButton(
                    icon: Icons.delete_outline_rounded,
                    label: "Eliminar",
                    color: AppColors.expense,
                    onTap: () => _confirmDelete(context),
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
      ),
    );
  }

  void _showEnterMovementDialog(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (_) => _EnterFrequentMovementDialog(frequent: frequent),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          "Eliminar Frecuente",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "¿Estás seguro de que deseas eliminar este frecuente? Se archivará para mantener la trazabilidad.",
          style: TextStyle(color: AppColors.textLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              "Cancelar",
              style: TextStyle(color: AppColors.textFaded),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<FrequentMovementProvider>().archiveFrequent(
                frequent.id,
              );
              if (ctx.mounted) {
                Navigator.pop(ctx);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.expense,
              foregroundColor: AppColors.textOnPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );
  }
}

class _EnterFrequentMovementDialog extends StatefulWidget {
  final FrequentMovementEntity frequent;

  const _EnterFrequentMovementDialog({required this.frequent});

  @override
  State<_EnterFrequentMovementDialog> createState() =>
      _EnterFrequentMovementDialogState();
}

class _EnterFrequentMovementDialogState
    extends State<_EnterFrequentMovementDialog> {
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.frequent.amount.toString();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final movementProv = context.watch<MovementProvider>();

    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: const Icon(
              Icons.add_circle_outline,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            "Ingresar Movimiento",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Confirma los detalles para '${widget.frequent.description}':",
              style: const TextStyle(fontSize: 13, color: AppColors.textLight),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _amountController,
              label: "Monto",
              icon: Icons.attach_money,
              isNumeric: true,
            ),
            const SizedBox(height: 8),
            _buildPaymentMethodDropdown(movementProv),
          ],
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Cancelar",
                  style: TextStyle(color: AppColors.textFaded),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _enter(context),
                child: const Text("Confirmar"),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentMethodDropdown(MovementProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 25,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
            DropdownButtonFormField<String>(
              initialValue: _selectedPaymentMethod,
              decoration: _inputStyle("Método de Pago", Icons.payment),
              items: provider.paymentMethods
                  .map(
                    (m) => DropdownMenuItem(value: m.id, child: Text(m.name)),
                  )
                  .toList(),
              onChanged: (val) => setState(() => _selectedPaymentMethod = val),
              validator: (v) => v == null ? "Requerido" : null,
              borderRadius: BorderRadius.circular(16),
              dropdownColor: AppColors.surface,
            ),
          ],
        ),
      ],
    );
  }

  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textLight),
      prefixIcon: Icon(icon, color: AppColors.primary),
      filled: false,
      helperText: ' ',
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  void _enter(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final frequentProv = context.read<FrequentMovementProvider>();
      final periodProv = context.read<BillingPeriodProvider>();
      final settingsProv = context.read<SettingsProvider>();
      final movementProv = context.read<MovementProvider>();

      await frequentProv.enterMovement(
        frequent: widget.frequent,
        amount: int.parse(_amountController.text),
        paymentMethodId: _selectedPaymentMethod!,
        billingPeriodId: periodProv.selectedPeriodId,
        startDay: settingsProv.settings.startDay,
      );

      await movementProv.refreshData();

      if (context.mounted) Navigator.pop(context);
    }
  }
}
