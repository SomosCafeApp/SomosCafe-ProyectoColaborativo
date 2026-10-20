import 'package:flutter/material.dart';

import '../../animations/animations.dart';
import '../../core/constants/app_colors.dart';
import 'terms_content.dart';

/// Tarjeta de una sección: icono en burbuja de color, título numerado y texto.
class TermsSectionCard extends StatelessWidget {
  final int number;
  final TermsSection section;

  const TermsSectionCard({
    super.key,
    required this.number,
    required this.section,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardColor = theme.cardTheme.color ??
        (isDark ? AppColors.darkSurface : AppColors.lightSurface);
    final titleColor = theme.colorScheme.onSurface;
    final bodyColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return SoftFadeIn(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: section.accent.withValues(alpha: isDark ? 0.22 : 0.16),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(section.icon, color: section.accent, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '$number. ${section.title}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              section.body,
              style: TextStyle(fontSize: 13.5, height: 1.55, color: bodyColor),
            ),
          ],
        ),
      ),
    );
  }
}
