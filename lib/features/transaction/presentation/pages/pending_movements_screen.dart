import 'package:cashify/core/theme/app_colors.dart';
import 'package:cashify/core/utils/formatters.dart';
import 'package:cashify/features/transaction/domain/entities/movement_entity.dart';
import 'package:cashify/features/transaction/presentation/providers/movement_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

class PendingMovementsScreen extends StatelessWidget {
  const PendingMovementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Movimientos Pendientes"),
        centerTitle: true,
      ),
      body: Consumer<MovementProvider>(
        builder: (context, provider, child) {
          final pendingItems = provider.movements
              .where((m) => !m.isCompleted)
              .toList();

          if (pendingItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 64,
                    color: AppColors.textFaded,
                  ),
                  const SizedBox(height: 16),

                  Text(
                    "¡Todo al día!\nNo tienes movimientos pendientes.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textLight, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          final groupedItems = groupBy(
            pendingItems,
            (MovementEntity m) => m.categoryId,
          );

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: groupedItems.keys.length,
            itemBuilder: (context, index) {
              final categoryId = groupedItems.keys.elementAt(index);
              final movements = groupedItems[categoryId]!;

              final bool isIngreso = provider.incomeCategoryIds.contains(
                categoryId,
              );
              final Color categoryColor = isIngreso
                  ? AppColors.income
                  : AppColors.expense;

              final categoryTotal = movements.fold<double>(
                0,
                (sum, item) => sum + (item.amount * item.quantity),
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
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
                            fontSize: 13,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          Formatters.currencyWithSymbol(categoryTotal.toInt()),
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: categoryColor.withValues(alpha: 0.8),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...movements.map(
                    (movement) => _buildMovementItem(
                      context,
                      movement,
                      provider,
                      isIngreso,
                    ),
                  ),
                  const SizedBox(height: 12),

                  const Divider(
                    indent: 20,
                    endIndent: 20,
                    thickness: 0.5,
                    color: AppColors.divider,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMovementItem(
    BuildContext context,
    MovementEntity movement,
    MovementProvider provider,
    bool isIngreso,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 12, right: 4),
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: (isIngreso ? AppColors.income : AppColors.expense)
              .withValues(alpha: 0.1),
          child: Icon(
            Icons.receipt_long_outlined,
            size: 18,
            color: isIngreso ? AppColors.income : AppColors.expense,
          ),
        ),
        title: Text(
          movement.description,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (movement.source.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  "Origen: ${movement.source}",
                  style: TextStyle(color: AppColors.textLight, fontSize: 11),
                ),
              ),
            Text(
              "${Formatters.currencyWithSymbol(movement.amount)} x ${movement.quantity}",
              style: TextStyle(color: AppColors.textFaded, fontSize: 11),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              Formatters.currencyWithSymbol(movement.totalAmount),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isIngreso ? AppColors.income : AppColors.expense,
              ),
            ),
            _buildPopupMenu(context, movement, provider),
          ],
        ),
      ),
    );
  }

  Widget _buildPopupMenu(
    BuildContext context,
    MovementEntity movement,
    MovementProvider provider,
  ) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, size: 20, color: AppColors.textFaded),
      padding: EdgeInsets.zero,
      onSelected: (value) async {
        if (value == 'complete') {
          await provider.toggleCompletion(movement);
        } else if (value == 'delete') {
          _showDeleteConfirmation(context, movement, provider);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'complete',
          child: ListTile(
            leading: Icon(Icons.check_circle_outline, color: AppColors.success),
            title: Text('Completar'),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete_outline, color: AppColors.danger),
            title: Text('Eliminar'),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    MovementEntity movement,
    MovementProvider provider,
  ) {
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
                  backgroundColor: AppColors.danger.withOpacity(0.1),
                  child: const Icon(
                    Icons.delete_sweep_rounded,
                    color: AppColors.danger,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  "¿Eliminar registro?",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                Text(
                  "Estás a punto de borrar '${movement.description}'. Esta operación no se puede deshacer.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textLight,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),

                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "Conservar",
                          style: TextStyle(
                            color: AppColors.textFaded,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.danger,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                          await provider.deleteMovement(movement.id);

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text("Movimiento eliminado"),
                                backgroundColor: AppColors.textPrimary,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                margin: const EdgeInsets.all(20),
                              ),
                            );
                          }
                        },
                        child: const Text(
                          "Eliminar",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
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
}
