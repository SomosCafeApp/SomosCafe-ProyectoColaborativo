import 'package:flutter/material.dart';

import '../widgets/profile/profile_sub_page_header.dart';

/// Configuración → Términos y Condiciones.
/// Por ahora solo tiene el header reutilizable; el contenido se agrega después.
class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: const Column(
        children: [
          ProfileSubPageHeader(
            title: 'Términos y Condiciones',
            subtitle: 'Lee nuestros términos',
          ),
          Expanded(child: SizedBox.shrink()),
        ],
      ),
    );
  }
}
