import 'package:cashify/core/theme/app_colors.dart';
import 'package:cashify/core/widgets/primary_app_bar.dart';
import 'package:cashify/features/settings/presentation/providers/settings_provider.dart';
import 'package:cashify/features/transaction/domain/entities/frequent_movement_entity.dart';
import 'package:cashify/features/transaction/presentation/pages/frequent_form_screen.dart';
import 'package:cashify/features/transaction/presentation/providers/billing_period_provider.dart';
import 'package:cashify/features/transaction/presentation/providers/frequent_movement_provider.dart';
import 'package:cashify/features/transaction/presentation/providers/movement_provider.dart';
import 'package:cashify/features/transaction/presentation/widgets/frequent_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FrequentMovementsScreen extends StatefulWidget {
  const FrequentMovementsScreen({super.key});

  @override
  State<FrequentMovementsScreen> createState() =>
      _FrequentMovementsScreenState();
}

class _FrequentMovementsScreenState extends State<FrequentMovementsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FrequentMovementProvider>().loadFrequent();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PrimaryAppBar(
        title: "Frecuentes",
        showAddButton: true,
        onAddPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FrequentFormScreen()),
        ),
      ),
      body: Consumer<FrequentMovementProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.frequents.isEmpty) {
            return const Center(
              child: Text("No tienes movimientos frecuentes aún."),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: _buildListItems(context, provider),
          );
        },
      ),
    );
  }

  List<Widget> _buildListItems(
    BuildContext context,
    FrequentMovementProvider provider,
  ) {
    final periodProv = context.watch<BillingPeriodProvider>();
    final settingsProv = context.watch<SettingsProvider>();
    final movementProv = context.watch<MovementProvider>();
    final selectedPeriodId = periodProv.selectedPeriodId;
    final list = provider.frequents.map((f) {
      final status = provider.getStatus(
        f,
        selectedPeriodId,
        settingsProv.settings.startDay,
        movementProv.movements,
      );
      final periodsAway = provider.getPeriodsAway(f, selectedPeriodId);
      final noHistory = provider.lastMovePeriodByFrequent[f.id] == null;

      int priority = 100;

      if (status == FrequentStatus.completed) {
        priority = 10;
      } else if (status == FrequentStatus.pending ||
          status == FrequentStatus.overdue) {
        priority = 20;
      } else if (!noHistory) {
        priority = 30;
      } else {
        priority = 40;
      }

      return {
        'frequent': f,
        'status': status,
        'periodsAway': periodsAway,
        'noHistory': noHistory,
        'priority': priority,
      };
    }).toList();

    list.sort((a, b) {
      final int pA = a['priority'] as int;
      final int pB = b['priority'] as int;
      if (pA != pB) return pA.compareTo(pB);

      final FrequentMovementEntity fA = a['frequent'] as FrequentMovementEntity;
      final FrequentMovementEntity fB = b['frequent'] as FrequentMovementEntity;
      return fA.description.compareTo(fB.description);
    });

    return list.map((item) {
      return _FrequentItemRow(
        frequent: item['frequent'] as FrequentMovementEntity,
        status: item['status'] as FrequentStatus,
        periodsAway: item['periodsAway'] as int?,
        noHistory: item['noHistory'] as bool,
      );
    }).toList();
  }
}

class _FrequentItemRow extends StatelessWidget {
  final FrequentMovementEntity frequent;
  final FrequentStatus status;
  final int? periodsAway;
  final bool noHistory;

  const _FrequentItemRow({
    required this.frequent,
    required this.status,
    required this.periodsAway,
    required this.noHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: AppColors.surface,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: _buildStatusIcon(status, noHistory: noHistory),
        title: Text(
          frequent.description,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        trailing: periodsAway != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getPeriodsColor(
                        periodsAway!,
                      ).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getPeriodsText(periodsAway!),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                  ),
                ],
              )
            : null,
        subtitle: RichText(
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
            style: const TextStyle(fontSize: 11),
            children: [
              TextSpan(
                text: _getCategoryName(
                  context,
                  frequent.categoryId,
                ).toUpperCase(),
                style: TextStyle(
                  color: _isIncome(context, frequent.categoryId)
                      ? AppColors.income
                      : AppColors.expense,
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
                text: frequent.source,
                style: TextStyle(
                  color: AppColors.textLight.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
        onTap: () => showDialog(
          context: context,
          builder: (_) => FrequentDetailDialog(frequent: frequent),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(FrequentStatus status, {bool noHistory = false}) {
    /* 1. Without movements (gray + plus icon) */
    if (noHistory) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.textLight.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(
            Icons.add_circle_outline,
            size: 18,
            color: AppColors.textLight,
          ),
        ),
      );
    }

    switch (status) {
      /* 2. Pending/Overdue in this period (Yellow + Clock) */
      case FrequentStatus.pending:
      case FrequentStatus.overdue:
        return Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: AppColors.iconWarning,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.access_time_filled,
              size: 18,
              color: AppColors.iconOnPrimary,
            ),
          ),
        );

      /* 3. Already entered this period (Green + Check) */
      case FrequentStatus.completed:
        return const Icon(
          Icons.check_circle,
          color: AppColors.iconSuccess,
          size: 32,
        );

      /* 4. No requires entry this month (Blue + Three dots) */
      case FrequentStatus.none:
        return Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: AppColors.iconIdle,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.more_horiz,
              color: AppColors.iconOnPrimary,
              size: 20,
            ),
          ),
        );
    }
  }

  Color _getPeriodsColor(int periodsAway) {
    if (periodsAway > 3) {
      return AppColors.iconSuccess;
    } else if (periodsAway > 1) {
      return AppColors.warning;
    } else {
      return Colors.orange;
    }
  }

  String _getPeriodsText(int periodsAway) {
    if (periodsAway == 1) {
      return "PRÓXIMO PERÍODO";
    } else {
      return "EN $periodsAway PERÍODOS";
    }
  }

  String _getCategoryName(BuildContext context, String catId) {
    try {
      final movementProv = context.read<MovementProvider>();
      return movementProv.categories.firstWhere((c) => c.id == catId).name;
    } catch (_) {
      return "Sin Categoría";
    }
  }

  bool _isIncome(BuildContext context, String catId) {
    try {
      final movementProv = context.read<MovementProvider>();
      return movementProv.incomeCategoryIds.contains(catId);
    } catch (_) {
      return false;
    }
  }
}
