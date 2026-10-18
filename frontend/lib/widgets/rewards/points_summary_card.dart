import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Resumen del historial: saldo actual, puntos ganados y canjeados.
class PointsSummaryCard extends StatelessWidget {
  final int balance;
  final int earned;
  final int spent;

  const PointsSummaryCard({
    super.key,
    required this.balance,
    required this.earned,
    required this.spent,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    Widget stat(String label, String value, Color color) => Expanded(
          child: Column(
            children: [
              Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
              const SizedBox(height: 2),
              Text(label, style: TextStyle(fontSize: 12, color: subtitleColor)),
            ],
          ),
        );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(isDark ? 40 : 10), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          stat('Saldo', '$balance', AppColors.primary),
          stat('Ganados', '+$earned', const Color(0xFF4CAF50)),
          stat('Canjeados', '-$spent', const Color(0xFFE57373)),
        ],
      ),
    );
  }
}
