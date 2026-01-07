import 'package:cashify/core/theme/app_colors.dart';
import 'package:cashify/features/shared/widgets/custom_drawer.dart';
import 'package:cashify/features/transaction/presentation/providers/movement_provider.dart';
import 'package:cashify/features/transaction/presentation/widgets/category_table.dart';
import 'package:cashify/features/transaction/presentation/widgets/mini_info_card.dart';
import 'package:cashify/features/transaction/presentation/widgets/summary_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
      context.read<MovementProvider>().loadAllData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Mis Movimientos"),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      drawer: const CustomDrawer(),
      body: Consumer<MovementProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.movements.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadAllData(),
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                SummaryCard(title: "TOTAL REAL", total: provider.realTotal),
                const SizedBox(height: 24),

                _buildSectionHeader("MOVIMIENTOS PLANIFICADOS"),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: CategoryTable(
                        groupedData: provider.plannedGrouped,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 1,
                      child: MiniInfoCard(
                        label: "Planificado",
                        amount: provider.plannedTotal,
                        color: provider.plannedTotal >= 0
                            ? AppColors.income
                            : AppColors.expense,
                      ),
                    ),
                  ],
                ),

                if (provider.hasExtraCategories) ...[
                  const Divider(
                    height: 50,
                    thickness: 1,
                    color: AppColors.divider,
                  ),
                  _buildSectionHeader("MOVIMIENTOS EXTRAS"),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: CategoryTable(
                          groupedData: provider.extraGrouped,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 1,
                        child: MiniInfoCard(
                          label: "Total Extras",
                          amount: provider.totalExtra,
                          color: provider.totalExtra >= 0
                              ? AppColors.income
                              : AppColors.expense,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.textLight,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
