import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Selector de dos pestañas de la pantalla de recompensas:
/// "Canjear" (catálogo) y "Mis cupones".
class RewardsTabBar extends StatelessWidget {
  final bool showMine;
  final int availableCount;
  final ValueChanged<bool> onChanged;

  const RewardsTabBar({
    super.key,
    required this.showMine,
    required this.availableCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle;

    Widget tab(String label, bool selected, VoidCallback onTap) => Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: selected ? Colors.white : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                ),
              ),
            ),
          ),
        );

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          tab('Canjear', !showMine, () => onChanged(false)),
          tab(availableCount > 0 ? 'Mis cupones ($availableCount)' : 'Mis cupones', showMine, () => onChanged(true)),
        ],
      ),
    );
  }
}
