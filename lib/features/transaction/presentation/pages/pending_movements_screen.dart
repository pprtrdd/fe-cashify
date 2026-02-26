import 'package:cashify/core/theme/app_colors.dart';
import 'package:cashify/core/utils/formatters.dart';
import 'package:cashify/core/widgets/primary_app_bar.dart';
import 'package:cashify/features/transaction/domain/entities/movement_entity.dart';
import 'package:cashify/features/transaction/presentation/providers/movement_provider.dart';
import 'package:cashify/features/transaction/presentation/widgets/compact_movement_row.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PendingMovementsScreen extends StatelessWidget {
  const PendingMovementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PrimaryAppBar(title: "Movimientos Pendientes"),
      body: Consumer<MovementProvider>(
        builder: (context, provider, child) {
          final pendingItems = provider.movements
              .where((m) => !m.isCompleted)
              .toList();

          if (pendingItems.isEmpty) {
            return const Center(child: Text("¡Todo al día!"));
          }

          final groupedItems = groupBy(
            pendingItems,
            (MovementEntity m) => m.categoryId,
          );

          return ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: groupedItems.keys.length,
            itemBuilder: (context, index) {
              final catId = groupedItems.keys.elementAt(index);
              final movs = groupedItems[catId]!;
              final isIncome = provider.incomeCategoryIds.contains(catId);
              final total = movs.fold<int>(0, (sum, m) => sum + m.totalAmount);

              return _CategoryGroup(
                name: provider.getCategoryName(catId),
                total: total,
                isIncome: isIncome,
                movements: movs,
                provider: provider,
              );
            },
          );
        },
      ),
    );
  }
}

class _CategoryGroup extends StatefulWidget {
  final String name;
  final int total;
  final bool isIncome;
  final List<MovementEntity> movements;
  final MovementProvider provider;

  const _CategoryGroup({
    required this.name,
    required this.total,
    required this.isIncome,
    required this.movements,
    required this.provider,
  });

  @override
  State<_CategoryGroup> createState() => _CategoryGroupState();
}

class _CategoryGroupState extends State<_CategoryGroup> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.isIncome
        ? AppColors.income
        : AppColors.expense;
    const textColor = AppColors.background;

    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    widget.name.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      color: textColor,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                Text(
                  Formatters.currencyWithSymbol(widget.total),
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: textColor,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                  color: textColor.withValues(alpha: 0.9),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: Column(
            children: widget.movements.map((m) {
              return CompactMovementRow(
                movement: m,
                provider: widget.provider,
                showStatusIcon: false,
              );
            }).toList(),
          ),
          secondChild: const SizedBox(width: double.infinity),
          crossFadeState: _isExpanded
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          duration: const Duration(milliseconds: 200),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
