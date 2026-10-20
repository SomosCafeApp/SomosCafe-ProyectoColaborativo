import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../widgets/profile/profile_sub_page_header.dart';
import '../widgets/recovery/recovery_button.dart';
import '../widgets/recovery/recovery_card.dart';
import '../widgets/recovery/recovery_field.dart';
import '../widgets/recovery/recovery_layout.dart';

/// Paso 2: el usuario ingresa el código de 6 dígitos que recibió por
/// correo, la nueva contraseña y su confirmación. Al cambiarla con
/// éxito, se cierra este flujo y se le pide volver a loguearse.
///
/// Con [useSession] = true se usa desde Configuración → Seguridad
/// ("¿Olvidaste tu contraseña?" con la sesión abierta): el código ya se
/// envió al correo de la cuenta logueada, se valida con la sesión (sin
/// volver a pedir el correo) y al terminar NO se cierra la sesión.
class ResetPasswordPage extends StatefulWidget {
  final String email;
  final bool useSession;

  const ResetPasswordPage({super.key, required this.email, this.useSession = false});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    final code = _codeController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa el código de 6 dígitos')),
      );
      return;
    }

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }

    // Misma política que el backend exige: mín. 6 caracteres,
    // mayúscula, minúscula, número y carácter especial.
    final passwordPolicy = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*()_+\-=\[\]{};:\x27"\\|,.<>/?]).{6,}$',
    );
    if (!passwordPolicy.hasMatch(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La contraseña debe tener mín. 6 caracteres, mayúscula, minúscula, número y carácter especial',
          ),
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = widget.useSession
        ? await auth.changePasswordWithCode(code: code, newPassword: password)
        : await auth.resetPassword(
            email: widget.email,
            code: code,
            newPassword: password,
          );

    if (!mounted) return;

    if (success && widget.useSession) {
      // Vuelve a Seguridad (que se cierra sola) sin cerrar la sesión.
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contraseña actualizada')),
      );
    } else if (success) {
      // Volvemos hasta el login (cierra Forgot + Reset) y pedimos
      // iniciar sesión de nuevo con la nueva contraseña.
      Navigator.popUntil(context, (route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contraseña actualizada. Inicia sesión de nuevo.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Código inválido o expirado')),
      );
    }
  }

  List<Widget> _buildForm(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final isLoading = context.watch<AuthProvider>().isLoading;

    return [
      RecoveryField(
        label: 'Código de verificación',
        hint: '000000',
        icon: Icons.tag,
        controller: _codeController,
        keyboardType: TextInputType.number,
        maxLength: 6,
        centered: true,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      ),
      const SizedBox(height: 18),
      RecoveryField(
        label: 'Nueva Contraseña',
        hint: '••••••••',
        icon: Icons.lock_outline,
        controller: _passwordController,
        obscure: _obscurePassword,
        onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
      ),
      const SizedBox(height: 6),
      Text(
        'Mín. 6 caracteres, mayúscula, minúscula, número y carácter especial',
        style: TextStyle(fontSize: 11, color: subtitleColor),
      ),
      const SizedBox(height: 18),
      RecoveryField(
        label: 'Confirmar Nueva Contraseña',
        hint: '••••••••',
        icon: Icons.lock_outline,
        controller: _confirmController,
        obscure: _obscureConfirm,
        onToggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm),
      ),
      const SizedBox(height: 24),
      RecoveryButton(
        label: 'Cambiar Contraseña',
        isLoading: isLoading,
        onPressed: _handleReset,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Con sesión abierta (Configuración → Seguridad) se mantiene el header
    // de las pestañas de perfil.
    if (widget.useSession) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(
          children: [
            const ProfileSubPageHeader(
              title: 'Cambiar contraseña',
              subtitle: 'Confirma el código de tu correo',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: RecoveryCard(children: _buildForm(context)),
              ),
            ),
          ],
        ),
      );
    }

    return RecoveryLayout(
      title: 'Nueva Contraseña',
      subtitle: 'Ingresa el código recibido y define tu nueva contraseña',
      children: _buildForm(context),
    );
  }
}
