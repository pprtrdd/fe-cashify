import 'package:cashify/features/transaction/presentation/widgets/compact_movement_row.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cashify/core/theme/app_colors.dart';
import 'package:cashify/features/transaction/presentation/providers/movement_provider.dart';

class MovementHistoryScreen extends StatelessWidget {
  const MovementHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Historial"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implementar filtros en Tarea 3
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Espacio para la barra de búsqueda (Tarea 3)
          _buildSearchBar(context),

          Expanded(
            child: Consumer<MovementProvider>(
              builder: (context, provider, child) {
                final movements = provider.filteredMovements;

                if (movements.isEmpty) {
                  return const Center(
                    child: Text("No se encontraron movimientos"),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  itemCount: movements.length,
                  itemBuilder: (context, index) {
                    final movement = movements[index];
                    return CompactMovementRow(
                      movement: movement,
                      provider: provider,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Buscar en descripción, origen o notas...",
          prefixIcon: const Icon(Icons.search, size: 20),
          isDense: true,
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          context.read<MovementProvider>().setSearchQuery(value);
        },
      ),
    );
  }
}
