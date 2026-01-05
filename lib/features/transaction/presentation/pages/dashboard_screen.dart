import 'package:cashify/core/auth/auth_service.dart';
import 'package:cashify/features/transaction/domain/entities/category_entity.dart';
import 'package:cashify/features/transaction/presentation/pages/movement_form_screen.dart';
import 'package:cashify/features/transaction/presentation/providers/movement_provider.dart';
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
      context.read<MovementProvider>().loadCategories();
      context.read<MovementProvider>().loadPaymentMethods();
      context.read<MovementProvider>().loadMovementsByMonth();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Movimientos"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () async {
              bool? confirm = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Cerrar Sesión"),
                  content: const Text("¿Estás seguro de que quieres salir?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancelar"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        "Salir",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await AuthService().signOut();
              }
            },
          ),
        ],
      ),
      body: Consumer<MovementProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.movements.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final plannedData = _getPlannedGrouped(provider);
          final extraData = _getExtraGrouped(provider);
          final totalExtra = extraData.values.fold(0, (sum, val) => sum + val);
          final bool hasExtraCategories = provider.categories.any(
            (c) => c.isExtra,
          );

          return RefreshIndicator(
            onRefresh: () => provider.loadMovementsByMonth(),
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildSummaryCard("TOTAL REAL", provider.realTotal),
                const SizedBox(height: 24),

                const Text(
                  "MOVIMIENTOS PLANIFICADOS",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildCategoryTable(plannedData)),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: _buildSmallPlannedCard(provider.plannedTotal),
                      ),
                    ),
                  ],
                ),
                if (hasExtraCategories) ...[
                  const Divider(height: 50, thickness: 1),
                  const Text(
                    "MOVIMIENTOS EXTRAS",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _buildCategoryTable(extraData)),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: _buildSmallExtraCard(totalExtra),
                        ),
                      ),
                    ],
                  ),
                ],
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
        label: const Text("Nuevo Gasto"),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard(String title, int total) {
    final bool isNegative = total < 0;
    final String displayTotal = total.abs().toString();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isNegative
                ? [Colors.red.shade700, Colors.red.shade400]
                : [Colors.green.shade700, Colors.green.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "${isNegative ? '- ' : '+ '}\$$displayTotal",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTable(Map<String, int> groupedData) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Item",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              Text(
                "Monto",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        ...groupedData.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(entry.key, style: const TextStyle(fontSize: 14)),
                Text(
                  "${entry.value < 0 ? '-' : '+'} \$${entry.value.abs()}",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: entry.value < 0
                        ? Colors.red.shade700
                        : Colors.green.shade700,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSmallPlannedCard(int amount) {
    final bool isNegative = amount < 0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Planificado",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "${isNegative ? '-' : '+'} \$${amount.abs()}",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isNegative ? Colors.red.shade700 : Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallExtraCard(int amount) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          const Text(
            "Total Extras",
            style: TextStyle(fontSize: 12, color: Colors.orange),
          ),
          const SizedBox(height: 4),
          Text(
            "\$${amount.abs()}",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: amount < 0 ? Colors.red : Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, int> _getPlannedGrouped(MovementProvider provider) {
    final categoriesList = provider.categories.cast<CategoryEntity>();
    Map<String, int> grouped = {};

    for (var cat in categoriesList) {
      if (!cat.isExtra) {
        grouped[cat.name] = 0;
      }
    }

    for (var mov in provider.movements) {
      final cat = categoriesList.firstWhere(
        (c) => c.id == mov.categoryId,
        orElse: () =>
            CategoryEntity(id: '', name: '', isExpense: true, isExtra: false),
      );

      if (!cat.isExtra && grouped.containsKey(cat.name)) {
        int value = cat.isExpense ? -mov.amount : mov.amount;
        grouped[cat.name] = grouped[cat.name]! + value;
      }
    }
    return grouped;
  }

  Map<String, int> _getExtraGrouped(MovementProvider provider) {
    final categoriesList = provider.categories.cast<CategoryEntity>();
    Map<String, int> grouped = {};

    for (var cat in categoriesList) {
      if (cat.isExtra) {
        grouped[cat.name] = 0;
      }
    }

    for (var mov in provider.movements) {
      final cat = categoriesList.firstWhere(
        (c) => c.id == mov.categoryId,
        orElse: () =>
            CategoryEntity(id: '', name: '', isExpense: true, isExtra: true),
      );

      if (cat.isExtra && grouped.containsKey(cat.name)) {
        int value = cat.isExpense ? -mov.amount : mov.amount;
        grouped[cat.name] = grouped[cat.name]! + value;
      }
    }
    return grouped;
  }
}
