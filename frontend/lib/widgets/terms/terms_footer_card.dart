import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'terms_content.dart';

/// Tarjeta final con el correo de contacto y los derechos reservados.
class TermsFooterCard extends StatelessWidget {
  const TermsFooterCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.accentYellow.withValues(alpha: isDark ? 0.10 : 0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.accentYellow.withValues(alpha: 0.25),
        ),
      ),
      child: Text(
        'Para preguntas sobre estos términos, escríbenos a '
        '$termsContactEmail\n$termsFooterLine',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, height: 1.6, color: textColor),
      ),
    );
  }
}
