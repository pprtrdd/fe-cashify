import 'package:cashify/core/utils/formatters.dart';
import 'package:flutter/material.dart';

class CategoryTable extends StatelessWidget {
  final Map<String, int> groupedData;

  const CategoryTable({super.key, required this.groupedData});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Item",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            Text(
              "Monto",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const Divider(),
        ...groupedData.entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(entry.key, style: const TextStyle(fontSize: 14)),
                Text(
                  "${entry.value < 0 ? '-' : '+'} ${Formatters.currencyWithSymbol(entry.value.abs())}",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: entry.value < 0
                        ? Colors.red.shade700
                        : Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
