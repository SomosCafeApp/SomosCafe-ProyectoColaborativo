import 'package:flutter/material.dart';

import '../common/styled_confirm_dialog.dart';

/// Diálogo de confirmación genérico del panel admin. Devuelve true solo
/// si el administrador pulsa el botón de confirmación.
Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
  IconData? icon,
}) {
  return showStyledConfirmDialog(
    context,
    icon: icon ??
        (destructive ? Icons.warning_amber_rounded : Icons.help_outline_rounded),
    title: title,
    message: message,
    confirmLabel: confirmLabel,
    cancelLabel: 'No',
    destructive: destructive,
  );
}
