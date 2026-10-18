import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/utils/password_policy.dart';
import '../providers/auth_provider.dart';
import '../widgets/profile/profile_sub_page_header.dart';
import '../widgets/settings/settings_input_field.dart';
import '../widgets/settings/settings_primary_button.dart';
import 'reset_password_page.dart';

/// Configuración → Seguridad: cambiar la contraseña de dos maneras.
///  1. Con la contraseña actual + la nueva escrita dos veces.
///  2. "¿Olvidaste tu contraseña?" (debajo del formulario): envía un código
///     al correo de la cuenta logueada y pasa directo al formulario de
///     cambio con código, sin pedir el correo.
class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _current.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _changeWithCurrent() async {
    final current = _current.text;
    final password = _new.text.trim();

    if (current.isEmpty || password.isEmpty || _confirm.text.trim().isEmpty) {
      _snack('Completa todos los campos');
      return;
    }
    if (password != _confirm.text.trim()) {
      _snack('Las contraseñas no coinciden');
      return;
    }
    if (!isValidPassword(password)) {
      _snack('La contraseña debe tener $passwordPolicyHint'.replaceFirst('Mín.', 'mín.'));
      return;
    }
    if (password == current) {
      _snack('La nueva contraseña debe ser distinta a la actual');
      return;
    }

    final auth = context.read<AuthProvider>();
    final ok = await auth.changePassword(currentPassword: current, newPassword: password);
    if (!mounted) return;

    if (ok) {
      _snack('Contraseña actualizada');
      Navigator.pop(context);
    } else {
      _snack(auth.errorMessage ?? 'No se pudo cambiar la contraseña');
    }
  }

  /// "¿Olvidaste tu contraseña?": código al correo de la cuenta y salto
  /// directo al formulario de cambio con código.
  Future<void> _forgotPassword() async {
    final auth = context.read<AuthProvider>();
    final email = auth.user?.email ?? '';

    final sent = await auth.requestOwnPasswordCode();
    if (!mounted) return;

    if (!sent) {
      _snack(auth.errorMessage ?? 'No se pudo enviar el código');
      return;
    }

    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ResetPasswordPage(email: email, useSession: true)),
    );
    if (changed == true && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          const ProfileSubPageHeader(
            title: 'Seguridad',
            subtitle: 'Cambia tu contraseña',
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SettingsInputField(
                    label: 'Contraseña actual',
                    controller: _current,
                    icon: Icons.lock_outline,
                    hint: '••••••••',
                    obscure: true,
                  ),
                  const SizedBox(height: 16),
                  SettingsInputField(
                    label: 'Nueva contraseña',
                    controller: _new,
                    icon: Icons.lock_reset_rounded,
                    hint: '••••••••',
                    obscure: true,
                    helper: passwordPolicyHint,
                  ),
                  const SizedBox(height: 16),
                  SettingsInputField(
                    label: 'Confirmar nueva contraseña',
                    controller: _confirm,
                    icon: Icons.lock_reset_rounded,
                    hint: '••••••••',
                    obscure: true,
                  ),
                  const SizedBox(height: 24),
                  SettingsPrimaryButton(
                    label: 'Cambiar contraseña',
                    isLoading: isLoading,
                    onPressed: _changeWithCurrent,
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: isLoading ? null : _forgotPassword,
                      child: const Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      'Te enviaremos un código al correo de tu cuenta.',
                      style: TextStyle(fontSize: 11, color: subtitleColor),
                    ),
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
