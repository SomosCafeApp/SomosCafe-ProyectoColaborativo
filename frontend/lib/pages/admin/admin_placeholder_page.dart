import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/profile/profile_sub_page_header.dart';

/// Pantalla temporal para una sección del panel admin que todavía no
/// se ha construido (Pedidos, Productos, Promociones, Eventos,
/// Notificaciones llegan en pasos siguientes). Evita enlaces rotos en
/// AdminHomePage mientras se construye cada sección una por una.
class AdminPlaceholderPage extends StatelessWidget {
  final String title;
  final IconData icon;

  const AdminPlaceholderPage({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitleColor =
        theme.brightness == Brightness.dark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          ProfileSubPageHeader(title: title, subtitle: 'Próximamente'),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 56, color: subtitleColor),
                  const SizedBox(height: 16),
                  Text(
                    'Esta sección se implementará en un próximo paso.',
                    style: TextStyle(color: subtitleColor, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
