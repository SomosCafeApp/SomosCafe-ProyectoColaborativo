import 'package:flutter/material.dart';

/// Título de una sección de la pantalla de confirmación del pedido.
class ConfirmSectionTitle extends StatelessWidget {
  final String text;

  const ConfirmSectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      );
}
