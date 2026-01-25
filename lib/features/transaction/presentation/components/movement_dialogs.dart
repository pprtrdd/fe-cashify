import 'package:flutter/material.dart';
import 'package:cashify/core/theme/app_colors.dart';
import 'package:cashify/features/transaction/domain/entities/movement_entity.dart';
import 'package:cashify/features/transaction/presentation/providers/movement_provider.dart';

class MovementDialogs {
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
      text: widget.movement.amount.toString(),
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
