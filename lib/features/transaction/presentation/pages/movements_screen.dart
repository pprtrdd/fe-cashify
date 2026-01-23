import 'package:cashify/core/theme/app_colors.dart';
import 'package:cashify/features/transaction/presentation/providers/movement_provider.dart';
import 'package:cashify/features/transaction/presentation/widgets/compact_movement_row.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MovementHistoryScreen extends StatefulWidget {
  const MovementHistoryScreen({super.key});

  @override
  State<MovementHistoryScreen> createState() => _MovementHistoryScreenState();
}

class _MovementHistoryScreenState extends State<MovementHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovementProvider>().clearFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Historial"),
        centerTitle: true,
        actions: [
          // Botón para limpiar todos los filtros rápidamente
          Consumer<MovementProvider>(
            builder: (context, provider, child) {
              final hasFilters =
                  provider.searchQuery.isNotEmpty ||
                  provider.filterCategoryId != null ||
                  provider.filterPaymentMethodId != null;

              if (!hasFilters) return const SizedBox.shrink();

              return IconButton(
                icon: const Icon(Icons.filter_alt_off),
                tooltip: "Limpiar filtros",
                onPressed: () => provider.clearFilters(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(context),
          _buildFilterBar(context), // Nueva barra de chips para filtros
          const Divider(height: 1),
          Expanded(
            child: Consumer<MovementProvider>(
              builder: (context, provider, child) {
                final movements = provider.pagedFilteredMovements;
                final allFiltered = provider.filteredMovements;
                final bool hasMore = movements.length < allFiltered.length;

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
                  itemCount: movements.length + (hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == movements.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: TextButton.icon(
                            onPressed: () => provider.loadNextPage(),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text("Cargar más"),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              backgroundColor: AppColors.primary.withValues(
                                alpha: 0.05,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      );
                    }

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
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
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

  Widget _buildFilterBar(BuildContext context) {
    return Consumer<MovementProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              _FilterChip(
                label: provider.filterCategoryId == null
                    ? "Categoría"
                    : provider.getCategoryName(provider.filterCategoryId!),
                isActive: provider.filterCategoryId != null,
                onTap: () => _showCategoryPicker(context, provider),
                onClear: () => provider.setCategoryId(null),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: provider.filterPaymentMethodId == null
                    ? "Pago"
                    : provider.getPaymentMethodName(
                        provider.filterPaymentMethodId!,
                      ),
                isActive: provider.filterPaymentMethodId != null,
                onTap: () => _showPaymentMethodPicker(context, provider),
                onClear: () => provider.setPaymentMethodId(null),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCategoryPicker(BuildContext context, MovementProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ListView(
        shrinkWrap: true,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Filtrar por Categoría",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ...provider.categories.map(
            (cat) => ListTile(
              title: Text(cat.name),
              trailing: provider.filterCategoryId == cat.id
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                provider.setCategoryId(cat.id);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentMethodPicker(
    BuildContext context,
    MovementProvider provider,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ListView(
        shrinkWrap: true,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Filtrar por Método de Pago",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ...provider.paymentMethods.map(
            (pm) => ListTile(
              title: Text(pm.name),
              trailing: provider.filterPaymentMethodId == pm.id
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                provider.setPaymentMethodId(pm.id);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? AppColors.primary : AppColors.textLight,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onClear,
                child: const Icon(
                  Icons.close,
                  size: 14,
                  color: AppColors.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
