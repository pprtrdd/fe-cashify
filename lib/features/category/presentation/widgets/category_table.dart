import 'package:cashify/core/theme/app_colors.dart';
import 'package:cashify/core/utils/formatters.dart';
import 'package:flutter/material.dart';

class CategoryTable extends StatelessWidget {
  final Map<String, int> groupedData;

  const CategoryTable({super.key, required this.groupedData});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Item",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textLight,
                fontSize: 12,
              ),
            ),
            Text(
              "Monto",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textLight,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const Divider(color: AppColors.divider),
        ...groupedData.entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  entry.key,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  "${entry.value < 0 ? '-' : '+'} ${Formatters.currencyWithSymbol(entry.value.abs())}",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: entry.value < 0
                        ? AppColors.expense
                        : AppColors.income,
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
