import 'package:cashify/core/theme/app_colors.dart';
import 'package:cashify/core/utils/formatters.dart';
import 'package:cashify/features/configuration/presentation/providers/settings_provider.dart';
import 'package:cashify/features/shared/widgets/custom_drawer.dart';
import 'package:cashify/features/transaction/presentation/pages/movement_form_screen.dart';
import 'package:cashify/features/transaction/presentation/pages/pending_movements_screen.dart';
import 'package:cashify/features/transaction/presentation/providers/billing_period_provider.dart';
import 'package:cashify/features/transaction/presentation/providers/movement_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? _lastPeriodLoaded;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final settingsProv = context.watch<SettingsProvider>();
    final periodProv = context.watch<BillingPeriodProvider>();
    final targetPeriod =
        periodProv.selectedPeriodId ??
        periodProv.getCurrentBillingPeriodId(settingsProv.settings);

    if (_lastPeriodLoaded != targetPeriod) {
      _lastPeriodLoaded = targetPeriod;
      Future.microtask(() => _refreshData());
    }
  }

  Future<void> _refreshData() async {
    final settingsProv = context.read<SettingsProvider>();
    final periodProv = context.read<BillingPeriodProvider>();
    final movementProv = context.read<MovementProvider>();

    if (settingsProv.settings.startDay == 1 && !settingsProv.isLoading) {
      await settingsProv.loadSettings();
    }

    if (!mounted) return;

    final billingPeriodId =
        periodProv.selectedPeriodId ??
        periodProv.getCurrentBillingPeriodId(settingsProv.settings);

    await movementProv.loadDataByBillingPeriod(billingPeriodId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: const Text("Cashify"),
        centerTitle: true,
        actions: const [_NotificationBadge()],
      ),
      body: Consumer<MovementProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: _refreshData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _MainBalanceCard(total: provider.totalBalance),
                  const SizedBox(height: 12),
                  const _CurrentPeriodLabel(),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _MiniInfoCard(
                        label: "Ingresos",
                        amount: provider.totalIncomes,
                        color: AppColors.income,
                        icon: Icons.add_circle_outline,
                      ),
                      const SizedBox(width: 12),
                      _MiniInfoCard(
                        label: "Gastos",
                        amount: provider.totalExpenses,
                        color: AppColors.expense,
                        icon: Icons.remove_circle_outline,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _CategoryTableBox(
                    title: "GASTOS PLANEADOS",
                    icon: Icons.list_alt_rounded,
                    data: provider.plannedGrouped,
                    totalSection: provider.plannedTotal,
                  ),
                  const SizedBox(height: 20),
                  if (provider.hasExtraCategories)
                    _CategoryTableBox(
                      title: "GASTOS EXTRAS",
                      icon: Icons.auto_awesome_outlined,
                      data: provider.extraGrouped,
                      totalSection: provider.totalExtra,
                    ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MovementFormScreen()),
          );
          if (mounted) _refreshData();
        },
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}

class _CurrentPeriodLabel extends StatelessWidget {
  const _CurrentPeriodLabel();

  @override
  Widget build(BuildContext context) {
    final periodProv = context.watch<BillingPeriodProvider>();
    final settingsProv = context.watch<SettingsProvider>();

    final activeId =
        periodProv.selectedPeriodId ??
        periodProv.getCurrentBillingPeriodId(settingsProv.settings);

    final range = periodProv.getRangeFromId(
      activeId,
      settingsProv.settings.startDay,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.calendar_view_month,
          size: 14,
          color: AppColors.textLight.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 6),
        Text(
          "${periodProv.formatId(activeId)} (${range.start.day}/${range.start.month} - ${range.end.day}/${range.end.month})",
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textLight.withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _CategoryTableBox extends StatelessWidget {
  final String title;
  final IconData icon;
  final Map<String, int> data;
  final double totalSection;

  const _CategoryTableBox({
    required this.title,
    required this.icon,
    required this.data,
    required this.totalSection,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Text(
                  Formatters.currencyWithSymbol(totalSection.abs()),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          if (data.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                "Sin movimientos registrados",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            )
          else
            ...data.entries.map((entry) {
              final isNegative = entry.value < 0;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          Formatters.currencyWithSymbol(entry.value.abs()),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isNegative
                                ? AppColors.expense
                                : AppColors.income,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (entry.key != data.keys.last)
                    Divider(
                      height: 1,
                      color: AppColors.border.withValues(alpha: 0.2),
                      indent: 16,
                      endIndent: 16,
                    ),
                ],
              );
            }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _MainBalanceCard extends StatelessWidget {
  final double total;

  const _MainBalanceCard({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            "Balance Total Real",
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            Formatters.currencyWithSymbol(total.toInt()),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniInfoCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  const _MiniInfoCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: AppColors.textLight),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              Formatters.currencyWithSymbol(amount.toInt()),
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationBadge extends StatelessWidget {
  const _NotificationBadge();

  @override
  Widget build(BuildContext context) {
    return Consumer<MovementProvider>(
      builder: (context, provider, _) {
        final pendingCount = provider.movements
            .where((m) => !m.isCompleted)
            .length;
        return IconButton(
          icon: Badge(
            backgroundColor: AppColors.notification,
            label: Text('$pendingCount'),
            isLabelVisible: pendingCount > 0,
            child: const Icon(Icons.notifications_none_rounded),
          ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PendingMovementsScreen()),
          ),
        );
      },
    );
  }
}
