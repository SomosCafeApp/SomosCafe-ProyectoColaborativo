import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../common/styled_confirm_dialog.dart';

/// Diálogo de confirmación para cerrar sesión.
Future<void> showLogoutDialog(BuildContext context) async {
  final authProvider = context.read<AuthProvider>();

  final confirmed = await showStyledConfirmDialog(
    context,
    icon: Icons.logout_rounded,
    title: '¿Cerrar Sesión?',
    message: '¿Estás seguro de que deseas cerrar tu sesión?',
    confirmLabel: 'Cerrar Sesión',
  );

  if (confirmed) authProvider.logout();
}
