import 'package:cashify/core/theme/app_colors.dart';
import 'package:cashify/core/utils/formatters.dart';
import 'package:cashify/features/transaction/domain/entities/movement_entity.dart';
import 'package:cashify/features/transaction/presentation/components/movement_dialogs.dart';
import 'package:cashify/features/transaction/presentation/pages/movement_form_screen.dart';
import 'package:cashify/features/transaction/presentation/providers/movement_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CompactMovementRow extends StatelessWidget {
  final MovementEntity movement;
  final MovementProvider provider;

  const CompactMovementRow({
    super.key,
    required this.movement,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = movement.isCompleted;
    final bool isIngreso = provider.incomeCategoryIds.contains(
      movement.categoryId,
    );
    final String categoryName = provider.getCategoryName(movement.categoryId);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      padding: const EdgeInsets.fromLTRB(12, 6, 4, 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted
              ? AppColors.border.withValues(alpha: 0.3)
              : AppColors.primary.withValues(alpha: 0.5),
          width: isCompleted ? 1 : 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 30,
            decoration: BoxDecoration(
              color: isIngreso ? AppColors.income : AppColors.expense,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        movement.description,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (movement.totalInstallments > 1) ...[
                      const SizedBox(width: 6),
                      Text(
                        "[${movement.currentInstallment}/${movement.totalInstallments}]",
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      categoryName.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: isIngreso ? AppColors.income : AppColors.expense,
                        letterSpacing: 0.5,
                      ),
                    ),
                    _buildSeparator(),
                    Text(
                      movement.source,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textLight,
                      ),
                    ),
                    if (movement.quantity > 1) ...[
                      _buildSeparator(),
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 10,
                        color: AppColors.textFaded,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        "x${movement.quantity}",
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textFaded,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Formatters.currencyWithSymbol(movement.totalAmount),
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: isIngreso ? AppColors.income : AppColors.expense,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.income.withValues(alpha: 0.1)
                      : AppColors.expense.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isCompleted ? "LISTO" : "PENDIENTE",
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? AppColors.income : AppColors.expense,
                  ),
                ),
              ),
            ],
          ),
          _buildActionsMenu(context),
        ],
      ),
    );
  }

  Widget _buildSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        "|",
        style: TextStyle(fontSize: 10, color: AppColors.divider),
      ),
    );
  }

  Widget _buildActionsMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, size: 18, color: AppColors.textFaded),
      onSelected: (value) async {
        switch (value) {
          case 'edit':
            _onEdit(context);
            break;
          case 'copy':
            _onCopy(context);
            break;
          case 'delete':
            _onDelete(context);
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: ListTile(
            leading: Icon(Icons.edit_outlined, size: 20),
            title: Text('Editar'),
            dense: true,
          ),
        ),
        const PopupMenuItem(
          value: 'copy',
          child: ListTile(
            leading: Icon(Icons.copy_outlined, size: 20),
            title: Text('Copiar'),
            dense: true,
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: ListTile(
            leading: Icon(
              Icons.delete_outline,
              color: AppColors.expense,
              size: 20,
            ),
            title: Text('Eliminar'),
            dense: true,
          ),
        ),
      ],
    );
  }

  void _onEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovementFormScreen(movement: movement),
      ),
    );
  }

  void _onCopy(BuildContext context) {
    final provider = context.read<MovementProvider>();
    final newMovement = provider.prepareCopy(movement);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovementFormScreen(movement: newMovement),
      ),
    );
  }

  void _onDelete(BuildContext context) {
    MovementDialogs.showDeleteConfirmation(
      context: context,
      movement: movement,
      provider: provider,
    );
  }
}
