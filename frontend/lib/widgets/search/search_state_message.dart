import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class SearchStateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const SearchStateMessage({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor = theme.colorScheme.onSurface;
    final subtitleColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    final circleBg = isDark
        ? const Color(0xFF382921)
        : const Color(0xFFE2CBB4).withOpacity(0.4);

    final iconColor = isDark
        ? const Color(0xFFD4BBA5)
        : AppColors.primary;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: circleBg,
            ),
            child: Icon(icon, size: 36, color: iconColor),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: subtitleColor,
            ),
          ),
        ],
      ),
    );
  }
}