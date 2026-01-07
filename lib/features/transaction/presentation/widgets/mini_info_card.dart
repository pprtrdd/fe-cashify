import 'package:cashify/core/utils/formatters.dart';
import 'package:flutter/material.dart';

class MiniInfoCard extends StatelessWidget {
  final String label;
  final int amount;
  final Color color;

  const MiniInfoCard({
    super.key,
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bool isNeg = amount < 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            "${isNeg ? '-' : '+'} ${Formatters.currencyWithSymbol(amount.abs())}",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isNeg ? Colors.red.shade700 : Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
