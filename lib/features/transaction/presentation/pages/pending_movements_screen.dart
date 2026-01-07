import 'package:cashify/core/utils/formatters.dart';
import 'package:cashify/features/transaction/domain/entities/movement_entity.dart';
import 'package:cashify/features/transaction/presentation/providers/movement_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

class PendingMovementsScreen extends StatelessWidget {
  const PendingMovementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Movimientos Pendientes")),
      body: Consumer<MovementProvider>(
        builder: (context, provider, child) {
          final pendingItems = provider.movements
              .where((m) => !m.isCompleted)
              .toList();

          if (pendingItems.isEmpty) {
            return const Center(child: Text("No hay pendientes ✨"));
          }

          final groupedItems = groupBy(
            pendingItems,
            (MovementEntity m) => m.categoryId,
          );

          return ListView.builder(
            itemCount: groupedItems.keys.length,
            itemBuilder: (context, index) {
              String categoryId = groupedItems.keys.elementAt(index);
              List<MovementEntity> movements = groupedItems[categoryId]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      provider.getCategoryName(categoryId),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  ...movements.map(
                    (movement) =>
                        _buildMovementItem(context, movement, provider),
                  ),
                  const Divider(),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMovementItem(
    BuildContext context,
    MovementEntity movement,
    MovementProvider provider,
  ) {
    final totalAmount = movement.quantity * movement.amount;
    /* TODO: Validar si es la forma correcta de obtener el proveedor de categorías */
    final bool isIngreso = provider.incomeCategoryIds.contains(
      movement.categoryId,
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      elevation: 0.5,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isIngreso
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.red.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isIngreso ? Icons.arrow_upward : Icons.arrow_downward,
            color: isIngreso ? Colors.green : Colors.red,
            size: 20,
          ),
        ),
        title: Text(
          movement.description,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (movement.source.isNotEmpty)
              Text(
                "Origen: ${movement.source}",
                style: const TextStyle(fontSize: 13),
              ),
            Text(
              "${Formatters.currencyWithSymbol(movement.amount)} x ${movement.quantity}",
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              Formatters.currencyWithSymbol(totalAmount),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isIngreso ? Colors.green.shade700 : Colors.black,
              ),
            ),
            const SizedBox(width: 8),
            _buildPopupMenu(context, movement, provider),
          ],
        ),
      ),
    );
  }

  Widget _buildPopupMenu(
    BuildContext context,
    MovementEntity movement,
    MovementProvider provider,
  ) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'complete') {
          await provider.updateMovement(movement.copyWith(isCompleted: true));
        } else if (value == 'delete') {
          await provider.deleteMovement(movement.id);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'complete',
          child: ListTile(
            leading: Icon(Icons.check, color: Colors.green),
            title: Text('Completar'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete, color: Colors.red),
            title: Text('Eliminar'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}
