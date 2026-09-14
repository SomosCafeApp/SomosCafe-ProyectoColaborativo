import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class HomeDivider extends StatelessWidget {
  const HomeDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryBrown = theme.colorScheme.primary;
    final dividerColor = isDark
        ? AppColors.darkSurfaceSubtle
        : theme.colorScheme.onSurface.withOpacity(0.08);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: Divider(color: dividerColor, thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 12,
                  color: isDark ? AppColors.accentYellow : primaryBrown.withOpacity(0.6),
                ),
                const SizedBox(width: 6),
                Text(
                  'EXPLORA MÁS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: Divider(color: dividerColor, thickness: 1)),
        ],
      ),
    );
  }
}