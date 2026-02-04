import 'package:cashify/core/theme/app_colors.dart';
import 'package:cashify/core/utils/formatters.dart';
import 'package:cashify/features/transaction/domain/entities/movement_entity.dart';
import 'package:cashify/features/transaction/presentation/components/movement_dialogs.dart';
import 'package:cashify/features/transaction/presentation/pages/movement_form_screen.dart';
import 'package:cashify/features/transaction/presentation/providers/movement_provider.dart';
import 'package:flutter/material.dart';

enum MovementAction { copy, delete, edit, complete }

class CompactMovementRow extends StatelessWidget {
  final MovementEntity movement;
  final MovementProvider provider;
  final bool showStatusIcon;
  final List<MovementAction> actions;

  const CompactMovementRow({
    super.key,
    required this.movement,
    required this.provider,
    this.showStatusIcon = true,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final bool isIngreso = provider.incomeCategoryIds.contains(
      movement.categoryId,
    );
    final String categoryName = provider.getCategoryName(movement.categoryId);
    final Color categoryColor = isIngreso
        ? AppColors.income
        : AppColors.expense;

    return Container(
      width: double.infinity,
      color: AppColors.surface,
      child: InkWell(
        onTap: () => _handleEdit(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              if (showStatusIcon) ...[
                Icon(
                  movement.isCompleted
                      ? Icons.check_circle_rounded
                      : Icons.pending_rounded,
                  size: 18,
                  color: movement.isCompleted
                      ? AppColors.success
                      : AppColors.warning,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                flex: 3,
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
                              fontSize: 15,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (movement.totalInstallments > 1)
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Text(
                              "[${movement.currentInstallment}/${movement.totalInstallments}]",
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    RichText(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        style: const TextStyle(fontSize: 10.5),
                        children: [
                          TextSpan(
                            text: categoryName.toUpperCase(),
                            style: TextStyle(
                              color: categoryColor,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.3,
                            ),
                          ),
                          TextSpan(
                            text: " | ",
                            style: TextStyle(
                              color: AppColors.textLight.withValues(alpha: 0.4),
                            ),
                          ),
                          TextSpan(
                            text: movement.source,
                            style: TextStyle(
                              color: AppColors.textLight.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  Formatters.currencyWithSymbol(movement.totalAmount),
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: categoryColor,
                  ),
                ),
              ),
              _buildPopupMenu(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context) {
    if (actions.isEmpty) return const SizedBox.shrink();

    return PopupMenuButton<MovementAction>(
      icon: Icon(Icons.more_vert, size: 20, color: AppColors.textFaded),
      onSelected: (action) {
        switch (action) {
          case MovementAction.complete:
            MovementDialogs.showCompleteConfirmation(
              context: context,
              movement: movement,
              provider: provider,
            );
            break;
          case MovementAction.copy:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MovementFormScreen(
                  movement: provider.prepareCopy(movement),
                ),
              ),
            );
            break;
          case MovementAction.edit:
            _handleEdit(context);
            break;
          case MovementAction.delete:
            MovementDialogs.showDeleteConfirmation(
              context: context,
              movement: movement,
              provider: provider,
            );
            break;
        }
      },
      itemBuilder: (context) {
        return actions.map((action) {
          switch (action) {
            case MovementAction.complete:
              return PopupMenuItem(
                value: MovementAction.complete,
                enabled: !movement.isCompleted,
                child: const Text('Completar'),
              );
            case MovementAction.copy:
              return const PopupMenuItem(
                value: MovementAction.copy,
                child: Text('Copiar'),
              );
            case MovementAction.edit:
              return const PopupMenuItem(
                value: MovementAction.edit,
                child: Text('Editar'),
              );
            case MovementAction.delete:
              return const PopupMenuItem(
                value: MovementAction.delete,
                child: Text(
                  'Eliminar',
                  style: TextStyle(color: AppColors.expense),
                ),
              );
          }
        }).toList();
      },
    );
  }

  void _handleEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MovementFormScreen(movement: movement)),
    );
  }
}
