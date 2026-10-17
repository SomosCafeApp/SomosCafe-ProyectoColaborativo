import 'package:flutter/material.dart';

/// Diálogo de confirmación genérico del panel admin. Devuelve true solo
/// si el administrador pulsa el botón de confirmación.
Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('No'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(
            confirmLabel,
            style: destructive ? const TextStyle(color: Color(0xFFE53935)) : null,
          ),
        ),
      ],
    ),
  );

  return result == true;
}
