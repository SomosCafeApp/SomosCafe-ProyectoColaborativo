import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../widgets/profile/profile_sub_page_header.dart';
import '../widgets/terms/terms_content.dart';
import '../widgets/terms/terms_footer_card.dart';
import '../widgets/terms/terms_section_card.dart';

/// Configuración → Términos y Condiciones.
/// El texto vive en `widgets/terms/terms_content.dart`.
class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mutedColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          const ProfileSubPageHeader(
            title: 'Términos y Condiciones',
            subtitle: 'Lee nuestros términos',
          ),
          Expanded(
            child: ListView(
              // Espacio abajo para que la barra de navegación no tape el final.
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 110),
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 16),
                  child: Text(
                    'Última actualización: $termsLastUpdate',
                    style: TextStyle(fontSize: 12, color: mutedColor),
                  ),
                ),
                for (var i = 0; i < termsSections.length; i++) ...[
                  TermsSectionCard(number: i + 1, section: termsSections[i]),
                  const SizedBox(height: 16),
                ],
                const TermsFooterCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
