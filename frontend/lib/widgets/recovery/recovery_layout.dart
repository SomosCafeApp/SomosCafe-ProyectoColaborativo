import 'package:flutter/material.dart';

import 'recovery_card.dart';
import 'recovery_header.dart';

/// Estructura común: header con degradado y tarjeta que lo solapa.
class RecoveryLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;

  const RecoveryLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            RecoveryHeader(title: title, subtitle: subtitle),
            Transform.translate(
              offset: const Offset(0, -30),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: RecoveryCard(children: children),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
