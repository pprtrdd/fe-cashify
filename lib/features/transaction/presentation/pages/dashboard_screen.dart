import 'package:cashify/features/shared/widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cashify/core/theme/app_colors.dart';
import 'package:cashify/features/transaction/presentation/providers/movement_provider.dart';
import 'package:cashify/features/transaction/presentation/widgets/summary_card.dart';
import 'package:cashify/features/transaction/presentation/widgets/category_table.dart';
import 'package:cashify/features/transaction/presentation/widgets/mini_info_card.dart';
import 'package:cashify/features/transaction/presentation/pages/movement_form_screen.dart';
import 'package:cashify/features/transaction/presentation/pages/pending_movements_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: const Text("Cashify"),
        centerTitle: true,
        elevation: 0,
        actions: [_buildNotificationBadge(context)],
      ),
      body: Consumer<MovementProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadAllData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SummaryCard(
                    title: "Balance Total Real",
                    total: provider.realTotal,
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: MiniInfoCard(
                          label: "Planeado",
                          amount: provider.plannedTotal,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),

                      Expanded(
                        child: MiniInfoCard(
                          label: "Extras",
                          amount: provider.totalExtra,
                          color: AppColors.extra,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _buildSectionHeader("Gastos Planeados"),
                  const SizedBox(height: 8),

                  _buildTableCard(provider.plannedGrouped),
                  const SizedBox(height: 24),

                  if (provider.hasExtraCategories) ...[
                    _buildSectionHeader("Gastos Extras"),
                    const SizedBox(height: 8),

                    _buildTableCard(provider.extraGrouped),
                  ],
                  const SizedBox(height: 80),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        elevation: 4,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MovementFormScreen()),
        ),
        tooltip: 'Nuevo Movimiento',
        child: const Icon(Icons.add, color: Colors.white, size: 30),
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTableCard(Map<String, int> data) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: data.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    "Sin movimientos registrados",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              )
            : CategoryTable(groupedData: data),
      ),
    );
  }
}
