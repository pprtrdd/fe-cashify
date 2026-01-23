import 'package:cashify/features/transaction/presentation/components/movement_dialogs.dart';
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
          if (provider.isLoading && provider.movements.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

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
            key: ValueKey(pendingItems.length),
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
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
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
          const Divider(color: AppColors.divider),
          ...movements.map(
            (movement) => _MovementRow(
              movement: movement,
              isIngreso: isIngreso,
              onDelete: () => MovementDialogs.showDeleteConfirmation(
                context: context,
                movement: movement,
                provider:
                    provider, // El MovementProvider que ya tienes disponible
              ),
              onComplete: () => MovementDialogs.showCompleteConfirmation(
                context: context,
                movement: movement,
                provider: provider,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
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
                            color: AppColors.primary,
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
      color: AppColors.surface,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        if (value == 'complete') onComplete();
        if (value == 'delete') onDelete();
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'complete',
          child: ListTile(
            leading: Icon(Icons.check_circle_outline, color: AppColors.income),
            title: Text('Completar'),
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete_outline, color: AppColors.expense),
            title: Text('Eliminar'),
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}
