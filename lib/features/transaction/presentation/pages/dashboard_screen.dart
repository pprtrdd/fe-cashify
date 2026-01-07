import 'package:cashify/features/shared/widgets/custom_drawer.dart';
import 'package:cashify/features/transaction/presentation/pages/movement_form_screen.dart';
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
    const Color incomeColor = Colors.green;
    const Color expenseColor = Colors.red;

    return Scaffold(
      appBar: AppBar(title: const Text("Mis Movimientos"), centerTitle: true),
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
                SummaryCard(
                  title: "TOTAL REAL",
                  total: provider.realTotal,
                ),
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
                            ? incomeColor
                            : expenseColor,
                      ),
                    ),
                  ],
                ),

                if (provider.hasExtraCategories) ...[
                  const Divider(height: 50, thickness: 1),
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
                              ? incomeColor
                              : expenseColor,
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MovementFormScreen()),
          );
        },
        label: const Text("Nuevo Movimiento"),
        icon: const Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
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
          color: Colors.grey[700],
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
