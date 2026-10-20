import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../widgets/recovery/recovery_button.dart';
import '../widgets/recovery/recovery_field.dart';
import '../widgets/recovery/recovery_layout.dart';
import 'reset_password_page.dart';

/// Paso 1: el usuario ingresa el correo del que quiere recuperar
/// la contraseña. Al enviarlo, el backend manda un código de 6
/// dígitos y navegamos al paso 2 (ResetPasswordPage).
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    final email = _emailController.text.trim();
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un correo válido')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.requestPasswordRecovery(email);

    if (!mounted) return;

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordPage(email: email),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'No se pudo enviar el código')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return RecoveryLayout(
      title: 'Recuperar Contraseña',
      subtitle: 'Ingresa tu correo registrado para recibir el código',
      children: [
        RecoveryField(
          label: 'Correo electrónico',
          hint: 'tu@email.com',
          icon: Icons.email_outlined,
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 24),
        RecoveryButton(
          label: 'Enviar Código',
          icon: Icons.send_outlined,
          isLoading: auth.isLoading,
          onPressed: _handleSend,
        ),
      ],
    );
  }
}
