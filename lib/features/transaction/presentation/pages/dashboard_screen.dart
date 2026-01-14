import 'package:cashify/features/configuration/presentation/providers/settings_provider.dart';
import 'package:cashify/features/shared/widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cashify/core/theme/app_colors.dart';
import 'package:cashify/core/utils/formatters.dart';
import 'package:cashify/features/transaction/presentation/providers/movement_provider.dart';
import 'package:cashify/features/transaction/presentation/pages/movement_form_screen.dart';
import 'package:cashify/features/transaction/presentation/pages/pending_movements_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    final settings = context.read<SettingsProvider>();
    if (settings.settings.startDay == 1 && settings.isLoading == false) {
      await settings.loadSettings();
    }

    if (mounted) {
      final billingPeriodId = context.read<SettingsProvider>().currentBillingPeriodId;
      await context.read<MovementProvider>().loadDataByBillingPeriod(billingPeriodId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProv = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: const Text("Cashify"),
        centerTitle: true,
        actions: [_buildNotificationBadge(context)],
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
                  _buildMainBalanceCard(provider.totalBalance),
                  const SizedBox(height: 12),
                  _buildPeriodSelector(context, settingsProv),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildMiniInfo(
                        "Ingresos",
                        provider.totalIncomes,
                        AppColors.income,
                        Icons.add_circle_outline,
                      ),
                      const SizedBox(width: 12),
                      _buildMiniInfo(
                        "Gastos",
                        provider.totalExpenses,
                        AppColors.expense,
                        Icons.remove_circle_outline,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildCategoryTableBox(
                    title: "GASTOS PLANEADOS",
                    icon: Icons.list_alt_rounded,
                    data: provider.plannedGrouped,
                    totalSection: provider.plannedTotal,
                  ),
                  const SizedBox(height: 20),
                  if (provider.hasExtraCategories)
                    _buildCategoryTableBox(
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
          _refreshData();
        },
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildPeriodSelector(BuildContext context, SettingsProvider settings) {
    final range = settings.currentBillingPeriodRange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_month_rounded, color: AppColors.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Período: ${settings.currentBillingPeriodId}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "${range.start.day}/${range.start.month} - ${range.end.day}/${range.end.month}",
                style: TextStyle(fontSize: 11, color: AppColors.textLight),
              ),
            ],
          ),
          const Spacer(),
          const Icon(Icons.keyboard_arrow_down_rounded),
        ],
      ),
    );
  }

  Widget _buildCategoryTableBox({
    required String title,
    required IconData icon,
    required Map<String, int> data,
    required double totalSection,
  }) {
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
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: AppColors.border.withValues(alpha: 0.2),
                indent: 16,
                endIndent: 16,
              ),
              itemBuilder: (context, index) {
                final entry = data.entries.elementAt(index);
                final isNegative = entry.value < 0;

                return Padding(
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
                );
              },
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildMainBalanceCard(double total) {
    return Container(
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

  Widget _buildMiniInfo(
    String label,
    double amount,
    Color color,
    IconData icon,
  ) {
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

  Widget _buildNotificationBadge(BuildContext context) {
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
