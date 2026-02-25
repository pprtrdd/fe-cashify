import 'package:cashify/core/theme/app_colors.dart';
import 'package:cashify/core/utils/billing_period_utils.dart';
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
      appBar: AppBar(title: const Text("Frecuentes"), centerTitle: true),
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
            children: _buildGroupedList(context, provider),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FrequentFormScreen()),
        ),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.textOnPrimary),
      ),
    );
  }

  List<Widget> _buildGroupedList(
    BuildContext context,
    FrequentMovementProvider provider,
  ) {
    final periodProv = context.watch<BillingPeriodProvider>();
    final selectedPeriodId = periodProv.selectedPeriodId;
    final List<Widget> widgets = [];
    final pendingFrequentsCurrentBillingPeriod = provider.frequents
        .where((f) => provider.shouldEnterInBillingPeriod(f, selectedPeriodId))
        .toList();
    if (pendingFrequentsCurrentBillingPeriod.isNotEmpty) {
      widgets.add(_buildHeader("Este período"));
      widgets.addAll(
        pendingFrequentsCurrentBillingPeriod.map(
          (f) => _FrequentItemRow(frequent: f, periodId: selectedPeriodId),
        ),
      );
    }

    final nextBillingPeriodId = BillingPeriodUtils.getNextBillingPeriodId(
      selectedPeriodId,
    );
    final pendingFrequentsNextBillingPeriod = provider.frequents
        .where(
          (f) => provider.shouldEnterInBillingPeriod(f, nextBillingPeriodId),
        )
        .where(
          (f) => !pendingFrequentsCurrentBillingPeriod.any((e) => e.id == f.id),
        )
        .toList();
    if (pendingFrequentsNextBillingPeriod.isNotEmpty) {
      widgets.add(_buildHeader("Próximo período"));
      widgets.addAll(
        pendingFrequentsNextBillingPeriod.map(
          (f) => _FrequentItemRow(frequent: f, periodId: nextBillingPeriodId),
        ),
      );
    }

    return widgets;
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _FrequentItemRow extends StatelessWidget {
  final FrequentMovementEntity frequent;
  final String periodId;

  const _FrequentItemRow({required this.frequent, required this.periodId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FrequentMovementProvider>();
    final movementProv = context.watch<MovementProvider>();
    final settingsProv = context.watch<SettingsProvider>();

    final status = provider.getStatus(
      frequent,
      periodId,
      settingsProv.settings.startDay,
      movementProv.movements,
      movementProv.lastLoadedBillingPeriodId,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: AppColors.surface,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: _buildStatusIcon(status),
        title: Text(
          frequent.description,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
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
                      color: _isIngreso(context, frequent.categoryId)
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
            const SizedBox(height: 2),
            Text(
              "Día ${frequent.paymentDay} de cada mes",
              style: const TextStyle(fontSize: 12, color: AppColors.textLight),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textLight),
        onTap: () => showDialog(
          context: context,
          builder: (_) => FrequentDetailDialog(frequent: frequent),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(FrequentStatus status) {
    switch (status) {
      case FrequentStatus.pending:
        return Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: AppColors.warning,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.more_horiz,
              size: 18,
              color: AppColors.textOnPrimary,
            ),
          ),
        );
      case FrequentStatus.completed:
        return const Icon(Icons.check_circle, color: AppColors.info, size: 32);
      case FrequentStatus.overdue:
        return const Icon(Icons.error, color: AppColors.danger, size: 32);
      case FrequentStatus.none:
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.textLight.withAlpha(50),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.do_disturb_on,
              size: 18,
              color: AppColors.textLight,
            ),
          ),
        );
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

  bool _isIngreso(BuildContext context, String catId) {
    try {
      final movementProv = context.read<MovementProvider>();
      return movementProv.incomeCategoryIds.contains(catId);
    } catch (_) {
      return false;
    }
  }
}
