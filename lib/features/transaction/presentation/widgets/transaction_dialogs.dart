import 'package:cashify/core/theme/app_colors.dart';
import 'package:cashify/core/utils/formatters.dart';
import 'package:cashify/features/shared/widgets/detail_row.dart';
import 'package:cashify/features/shared/widgets/item_detail_dialog.dart';
import 'package:cashify/features/transaction/domain/entities/transaction_entity.dart';
import 'package:cashify/features/transaction/presentation/pages/transaction_form_screen.dart';
import 'package:cashify/features/transaction/presentation/providers/transaction_provider.dart';
import 'package:flutter/material.dart';

class TransactionDialogs {
  static void showDetail({
    required BuildContext context,
    required TransactionEntity transaction,
    required TransactionProvider provider,
  }) {
    showDialog(
      context: context,
      builder: (_) =>
          TransactionDetailDialog(transaction: transaction, provider: provider),
    );
  }

  static void showDeleteConfirmation({
    required BuildContext context,
    required TransactionEntity transaction,
    required TransactionProvider provider,
  }) {
    final hasMoreInstallments = transaction.totalInstallments > 1;

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
                    : "Estás a punto de borrar '${transaction.description}'.",
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
                      await provider.deleteTransaction(transaction);
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
                        await provider.deleteTransactionGroup(transaction);
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
    required TransactionEntity transaction,
    required TransactionProvider provider,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          _CompleteTransactionDialog(transaction: transaction, provider: provider),
    );
  }
}

class _CompleteTransactionDialog extends StatefulWidget {
  final TransactionEntity transaction;
  final TransactionProvider provider;

  const _CompleteTransactionDialog({
    required this.transaction,
    required this.provider,
  });

  @override
  State<_CompleteTransactionDialog> createState() =>
      _CompleteTransactionDialogState();
}

class _CompleteTransactionDialogState extends State<_CompleteTransactionDialog> {
  late TextEditingController _amountController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: (widget.transaction.amount * widget.transaction.quantity).toString(),
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
              "Confirma el monto final para '${widget.transaction.description}':",
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
                    await widget.provider.confirmAndCompleteTransaction(
                      widget.transaction,
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

class TransactionDetailDialog extends StatelessWidget {
  final TransactionEntity transaction;
  final TransactionProvider provider;

  const TransactionDetailDialog({
    super.key,
    required this.transaction,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = provider.incomeCategoryIds.contains(transaction.categoryId);
    final categoryName = provider.getCategoryName(transaction.categoryId);
    final paymentMethodName = provider.getPaymentMethodName(
      transaction.paymentMethodId,
    );
    final color = isIncome ? AppColors.income : AppColors.expense;

    final billingDate = DateTime(
      transaction.billingPeriodYear,
      transaction.billingPeriodMonth,
    );

    return ItemDetailDialog(
      header: DialogHeader(
        icon: isIncome ? Icons.arrow_downward : Icons.arrow_upward_rounded,
        color: color,
        amount: Formatters.currencyWithSymbol(transaction.totalAmount),
        title: transaction.description,
        badgeText: categoryName.toUpperCase(),
        titleTrailing: transaction.frequentId != null
            ? const Icon(Icons.auto_awesome, size: 18, color: AppColors.primary)
            : null,
      ),
      detailSections: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: DetailRow(
                icon: Icons.info_outline_rounded,
                label: "Estado",
                value: transaction.isCompleted ? "Completado" : "Pendiente",
                valueColor: transaction.isCompleted
                    ? AppColors.success
                    : AppColors.warning,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DetailRow(
                icon: Icons.calendar_month_rounded,
                label: "Período",
                value: Formatters.monthYear(billingDate),
              ),
            ),
          ],
        ),
        const Divider(height: 24, color: AppColors.background),
        DetailRow(
          icon: Icons.store_rounded,
          label: "Origen/Lugar",
          value: transaction.source,
        ),
        const Divider(height: 24, color: AppColors.background),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: DetailRow(
                icon: Icons.numbers_rounded,
                label: "Cantidad",
                value: transaction.quantity.toString(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DetailRow(
                icon: Icons.attach_money_rounded,
                label: "Monto Unitario",
                value: Formatters.currencyWithSymbol(transaction.amount),
              ),
            ),
          ],
        ),
        const Divider(height: 24, color: AppColors.background),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: DetailRow(
                icon: Icons.pie_chart_rounded,
                label: "Cuotas",
                value:
                    "${transaction.currentInstallment}/${transaction.totalInstallments}",
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DetailRow(
                icon: Icons.calendar_today_rounded,
                label: "Fecha Registro",
                value: Formatters.date(transaction.createdAt),
              ),
            ),
          ],
        ),
        const Divider(height: 24, color: AppColors.background),
        DetailRow(
          icon: Icons.credit_card_rounded,
          label: "Método de Pago",
          value: paymentMethodName,
        ),
        if (transaction.notes != null && transaction.notes!.isNotEmpty) ...[
          const Divider(height: 24, color: AppColors.background),
          DetailRow(
            icon: Icons.notes_rounded,
            label: "Notas",
            value: transaction.notes!,
          ),
        ],
      ],
      actions: [
        DialogAction(
          icon: Icons.edit_rounded,
          label: "Editar",
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    TransactionFormScreen(transaction: transaction),
              ),
            );
          },
        ),
        DialogAction(
          icon: Icons.copy_rounded,
          label: "Copiar",
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TransactionFormScreen(
                  transaction: provider.prepareCopy(transaction),
                ),
              ),
            );
          },
        ),
        if (!transaction.isCompleted)
          DialogAction(
            icon: Icons.check_circle_outline_rounded,
            label: "Completar",
            color: AppColors.success,
            onTap: () {
              Navigator.pop(context);
              TransactionDialogs.showCompleteConfirmation(
                context: context,
                transaction: transaction,
                provider: provider,
              );
            },
          ),
        DialogAction(
          icon: Icons.delete_outline_rounded,
          label: "Eliminar",
          color: AppColors.expense,
          onTap: () {
            Navigator.pop(context);
            TransactionDialogs.showDeleteConfirmation(
              context: context,
              transaction: transaction,
              provider: provider,
            );
          },
        ),
      ],
    );
  }
}
