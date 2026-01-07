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
                color: isIngreso ? AppColors.income : AppColors.textPrimary,
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
          await provider.deleteMovement(movement.id);
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
}
