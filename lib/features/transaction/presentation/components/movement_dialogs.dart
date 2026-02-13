import 'package:cashify/core/theme/app_colors.dart';
import 'package:cashify/core/utils/formatters.dart';
import 'package:cashify/features/transaction/domain/entities/movement_entity.dart';
import 'package:cashify/features/transaction/presentation/pages/movement_form_screen.dart';
import 'package:cashify/features/transaction/presentation/providers/movement_provider.dart';
import 'package:flutter/material.dart';

class MovementDialogs {
  static void showDetail({
    required BuildContext context,
    required MovementEntity movement,
    required MovementProvider provider,
  }) {
    showDialog(
      context: context,
      builder: (_) =>
          _MovementDetailDialog(movement: movement, provider: provider),
    );
  }

  static void showDeleteConfirmation({
    required BuildContext context,
    required MovementEntity movement,
    required MovementProvider provider,
  }) {
    final hasMoreInstallments = movement.totalInstallments > 1;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: AppColors.surface,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.expense.withValues(alpha: 0.1),
                child: Icon(
                  hasMoreInstallments ? Icons.layers_clear : Icons.delete_sweep,
                  color: AppColors.expense,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                hasMoreInstallments ? "Eliminar Cuotas" : "¿Eliminar registro?",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                hasMoreInstallments
                    ? "Este movimiento tiene cuotas. ¿Deseas eliminar solo esta o todas las restantes?"
                    : "Estás a punto de borrar '${movement.description}'.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textLight, height: 1.4),
              ),
              const SizedBox(height: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.expense,
                      foregroundColor: AppColors.textOnPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      await provider.deleteMovement(movement);
                    },
                    child: Text(
                      hasMoreInstallments ? "Solo esta cuota" : "Eliminar",
                    ),
                  ),
                  if (hasMoreInstallments) ...[
                    const SizedBox(height: 8),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.expense,
                        side: const BorderSide(color: AppColors.expense),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        await provider.deleteMovementGroup(movement);
                      },
                      child: const Text("Todas las cuotas del grupo"),
                    ),
                  ],
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Cancelar",
                      style: TextStyle(color: AppColors.textFaded),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void showCompleteConfirmation({
    required BuildContext context,
    required MovementEntity movement,
    required MovementProvider provider,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          _CompleteMovementDialog(movement: movement, provider: provider),
    );
  }
}

class _CompleteMovementDialog extends StatefulWidget {
  final MovementEntity movement;
  final MovementProvider provider;

  const _CompleteMovementDialog({
    required this.movement,
    required this.provider,
  });

  @override
  State<_CompleteMovementDialog> createState() =>
      _CompleteMovementDialogState();
}

class _CompleteMovementDialogState extends State<_CompleteMovementDialog> {
  late TextEditingController _amountController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: (widget.movement.amount * widget.movement.quantity).toString(),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.income.withValues(alpha: 0.1),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: AppColors.income,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Monto Real",
            style: TextStyle(
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
          children: [
            Text(
              "Confirma el monto final para '${widget.movement.description}':",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textLight),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              autofocus: true,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 28,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                prefixText: "\$ ",
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (v) =>
                  (v == null || int.tryParse(v) == null || int.parse(v) <= 0)
                  ? "Monto inválido"
                  : null,
            ),
          ],
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancelar",
                  style: TextStyle(color: AppColors.textFaded),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.income,
                  foregroundColor: AppColors.textOnPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final newAmount = int.parse(_amountController.text);
                    Navigator.pop(context);
                    await widget.provider.confirmAndCompleteMovement(
                      widget.movement,
                      newAmount,
                    );
                  }
                },
                child: const Text("Confirmar"),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MovementDetailDialog extends StatelessWidget {
  final MovementEntity movement;
  final MovementProvider provider;

  const _MovementDetailDialog({required this.movement, required this.provider});

  @override
  Widget build(BuildContext context) {
    final isIngreso = provider.incomeCategoryIds.contains(movement.categoryId);
    final categoryName = provider.getCategoryName(movement.categoryId);
    final paymentMethodName = provider.getPaymentMethodName(
      movement.paymentMethodId,
    );
    final color = isIngreso ? AppColors.income : AppColors.expense;
    final amountStyle = TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w900,
      color: color,
    );

    final billingDate = DateTime(
      movement.billingPeriodYear,
      movement.billingPeriodMonth,
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
                      isIngreso
                          ? Icons.arrow_downward
                          : Icons.arrow_upward_rounded,
                      color: color,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    Formatters.currencyWithSymbol(movement.totalAmount),
                    style: amountStyle,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    movement.description,
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _DetailRow(
                      icon: Icons.info_outline_rounded,
                      label: "Estado",
                      value: movement.isCompleted ? "Completado" : "Pendiente",
                      valueColor: movement.isCompleted
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _DetailRow(
                      icon: Icons.calendar_month_rounded,
                      label: "Período",
                      value: Formatters.monthYear(billingDate),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24, color: AppColors.background),
              _DetailRow(
                icon: Icons.store_rounded,
                label: "Origen/Lugar",
                value: movement.source,
              ),
              const Divider(height: 24, color: AppColors.background),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _DetailRow(
                      icon: Icons.numbers_rounded,
                      label: "Cantidad",
                      value: movement.quantity.toString(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _DetailRow(
                      icon: Icons.attach_money_rounded,
                      label: "Monto Unitario",
                      value: Formatters.currencyWithSymbol(movement.amount),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24, color: AppColors.background),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _DetailRow(
                      icon: Icons.pie_chart_rounded,
                      label: "Cuotas",
                      value:
                          "${movement.currentInstallment}/${movement.totalInstallments}",
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _DetailRow(
                      icon: Icons.calendar_today_rounded,
                      label: "Fecha Registro",
                      value: Formatters.date(movement.createdAt),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24, color: AppColors.background),
              _DetailRow(
                icon: Icons.credit_card_rounded,
                label: "Método de Pago",
                value: paymentMethodName,
              ),
              if (movement.notes != null && movement.notes!.isNotEmpty) ...[
                const Divider(height: 24, color: AppColors.background),
                _DetailRow(
                  icon: Icons.notes_rounded,
                  label: "Notas",
                  value: movement.notes!,
                ),
              ],
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ActionButton(
                    icon: Icons.edit_rounded,
                    label: "Editar",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              MovementFormScreen(movement: movement),
                        ),
                      );
                    },
                  ),
                  _ActionButton(
                    icon: Icons.copy_rounded,
                    label: "Copiar",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MovementFormScreen(
                            movement: provider.prepareCopy(movement),
                          ),
                        ),
                      );
                    },
                  ),
                  if (!movement.isCompleted)
                    _ActionButton(
                      icon: Icons.check_circle_outline_rounded,
                      label: "Completar",
                      color: AppColors.success,
                      onTap: () {
                        Navigator.pop(context);
                        MovementDialogs.showCompleteConfirmation(
                          context: context,
                          movement: movement,
                          provider: provider,
                        );
                      },
                    ),
                  _ActionButton(
                    icon: Icons.delete_outline_rounded,
                    label: "Eliminar",
                    color: AppColors.expense,
                    onTap: () {
                      Navigator.pop(context);
                      MovementDialogs.showDeleteConfirmation(
                        context: context,
                        movement: movement,
                        provider: provider,
                      );
                    },
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
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.textLight),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
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
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppColors.textPrimary,
                ),
              ),
            ],
          ),
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
