import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// "Cómo ganar puntos": solo lista lo que el sistema otorga de verdad
/// (1 punto por cada \$1.000 en productos cuando un pedido se entrega,
/// mínimo 1 por pedido; ver utils/rewardsConfig.js en el backend).
class EarnPointsCard extends StatelessWidget {
  final int balance;

  const EarnPointsCard({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final background = isDark ? AppColors.darkSurfaceSubtle : const Color(0xFFFFFDE7);
    final iconBackground = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: AppColors.primary, size: 18),
              SizedBox(width: 6),
              Text('Cómo Ganar Puntos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: iconBackground,
                child: const Icon(Icons.local_cafe, size: 16, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Text('1 punto', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(width: 4),
              Expanded(
                child: Text('por cada \$1.000 en productos de un pedido entregado', style: TextStyle(color: subtitleColor)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('Mínimo 1 punto por pedido. Ahora tienes $balance puntos.', style: TextStyle(fontSize: 12, color: subtitleColor)),
        ],
      ),
    );
  }
}
