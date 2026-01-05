import 'package:cashify/core/auth/auth_service.dart';
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

          return RefreshIndicator(
            onRefresh: () => provider.loadMovementsByMonth(),
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildSummaryCard(provider),
                const SizedBox(height: 24),
                const Text(
                  "Movimientos Recientes",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                if (provider.movements.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Center(
                      child: Text("No hay movimientos registrados"),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.movements.length,
                    itemBuilder: (context, index) {
                      final movement = provider.movements[index];

                      final category = provider.categories.firstWhere(
                        (cat) => cat.id == movement.categoryId,
                      );
                      final bool isExpense = category.isExpense;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isExpense
                                ? Colors.red.withValues(alpha: 0.1)
                                : Colors.green.withValues(alpha: 0.1),
                            child: Icon(
                              isExpense
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              color: isExpense ? Colors.red : Colors.green,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            movement.description,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            "${movement.source} • ${category.name}", // Agregamos el nombre de la categoría
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          trailing: Text(
                            "${isExpense ? '-' : '+'} \$${movement.amount}",
                            style: TextStyle(
                              color: isExpense
                                  ? Colors.redAccent
                                  : Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
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

  Widget _buildSummaryCard(MovementProvider provider) {
    final movementsList = provider.movements;
    final categories = provider.categories;
    final total = movementsList.fold<int>(0, (sum, movement) {
      final category = categories.firstWhere(
        (cat) => cat.id == movement.categoryId,
      );

      if (category.isExpense) {
        return sum - movement.amount;
      } else {
        return sum + movement.amount;
      }
    });

    final bool isNegative = total < 0;
    final String displayTotal = total.abs().toStringAsFixed(0);

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
              isNegative ? "Balance Negativo" : "Balance del Mes",
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
}
