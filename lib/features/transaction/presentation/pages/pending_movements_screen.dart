import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import 'package:cashify/core/theme/app_colors.dart';
import 'package:cashify/core/utils/formatters.dart';
import 'package:cashify/features/transaction/domain/entities/movement_entity.dart';
import 'package:cashify/features/transaction/presentation/providers/movement_provider.dart';

class PendingMovementsScreen extends StatelessWidget {
  const PendingMovementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Movimientos Pendientes"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<MovementProvider>(
        builder: (context, provider, child) {
          final pendingItems = provider.movements
              .where((m) => !m.isCompleted)
              .toList();

          if (pendingItems.isEmpty) {
            return _buildEmptyState();
          }
          final groupedItems = groupBy(
            pendingItems,
            (MovementEntity m) => m.categoryId,
          );

          final keys = groupedItems.keys.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: keys.length,
            itemBuilder: (context, index) {
              final categoryId = keys[index];
              final movements = groupedItems[categoryId]!;

              return _CategoryGroupCard(
                categoryId: categoryId,
                movements: movements,
                provider: provider,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome,
            size: 64,
            color: AppColors.textFaded.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            "¡Todo al día!",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text(
            "No tienes movimientos pendientes.",
            style: TextStyle(color: AppColors.textLight, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class _CategoryGroupCard extends StatelessWidget {
  final String categoryId;
  final List<MovementEntity> movements;
  final MovementProvider provider;

  const _CategoryGroupCard({
    required this.categoryId,
    required this.movements,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final bool isIngreso = provider.incomeCategoryIds.contains(categoryId);
    final Color categoryColor = isIngreso
        ? AppColors.income
        : AppColors.expense;

    final categoryTotal = movements.fold<int>(
      0,
      (sum, item) => sum + item.totalAmount,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 12, 8),
            child: Row(
              children: [
                Icon(
                  isIngreso ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                  color: categoryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  provider.getCategoryName(categoryId).toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: categoryColor,
                    letterSpacing: 1.1,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Text(
                  Formatters.currencyWithSymbol(categoryTotal),
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: categoryColor,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          ...movements.map(
            (movement) => _MovementRow(
              movement: movement,
              isIngreso: isIngreso,
              onDelete: () => _showDeleteConfirmation(context, movement),
              onComplete: () => _showCompleteConfirmation(context, movement),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, MovementEntity movement) {
    final hasMoreInstallments = movement.totalInstallments > 1;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
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
                    hasMoreInstallments
                        ? Icons.layers_clear_rounded
                        : Icons.delete_sweep_rounded,
                    color: AppColors.expense,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  hasMoreInstallments
                      ? "Eliminar Cuotas"
                      : "¿Eliminar registro?",
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
                      : "Estás a punto de borrar '${movement.description}'. Esta operación no se puede deshacer.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textLight,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.expense,
                        foregroundColor: Colors.white,
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
        );
      },
    );
  }

  void _showCompleteConfirmation(
    BuildContext context,
    MovementEntity movement,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          _CompleteMovementDialog(movement: movement, provider: provider),
    );
  }
}

class _MovementRow extends StatelessWidget {
  final MovementEntity movement;
  final bool isIngreso;
  final VoidCallback onDelete;
  final VoidCallback onComplete;

  const _MovementRow({
    required this.movement,
    required this.isIngreso,
    required this.onDelete,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 4, top: 4, bottom: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movement.description,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    if (movement.totalInstallments > 1)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Text(
                          "[${movement.currentInstallment}/${movement.totalInstallments}]",
                          style: const TextStyle(
                            color: AppColors.income,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (movement.source.isNotEmpty)
                      Flexible(
                        child: Text(
                          "Origen: ${movement.source}",
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Formatters.currencyWithSymbol(movement.totalAmount),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isIngreso ? AppColors.income : AppColors.expense,
                  ),
                ),
                Text(
                  "${Formatters.currencyWithSymbol(movement.amount)} x ${movement.quantity}",
                  style: TextStyle(color: AppColors.textFaded, fontSize: 10),
                ),
              ],
            ),
          ),
          _buildPopupMenu(context),
        ],
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, size: 20, color: AppColors.textFaded),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        if (value == 'complete') {
          onComplete();
        } else if (value == 'delete') {
          onDelete();
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'complete',
          child: ListTile(
            leading: Icon(Icons.check_circle_outline, color: AppColors.income),
            title: Text('Completar'),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete_outline, color: AppColors.expense),
            title: Text('Eliminar'),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
      ],
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
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Confirma el monto final pagado/recibido para '${widget.movement.description}':",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textLight),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: false,
              ),
              textAlign: TextAlign.center,
              autofocus: true,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 28,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                prefixText: "\$ ",
                hintText: "0",
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                errorStyle: const TextStyle(fontSize: 11),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return "Ingresa un monto";
                final val = int.tryParse(value);
                if (val == null || val <= 0) {
                  return "El monto debe ser mayor a 0";
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                  foregroundColor: Colors.white,
                  elevation: 0,
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

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Movimiento registrado correctamente"),
                          backgroundColor: AppColors.income,
                        ),
                      );
                    }
                  }
                },
                child: const Text(
                  "Confirmar",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
