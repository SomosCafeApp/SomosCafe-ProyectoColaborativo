import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';

/// Paso 2: el usuario ingresa el código de 6 dígitos que recibió por
/// correo, la nueva contraseña y su confirmación. Al cambiarla con
/// éxito, se cierra este flujo y se le pide volver a loguearse.
class ResetPasswordPage extends StatefulWidget {
  final String email;

  const ResetPasswordPage({super.key, required this.email});

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
    final success = await auth.resetPassword(
      email: widget.email,
      code: code,
      newPassword: password,
    );

    if (!mounted) return;

    if (success) {
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

  Widget _buildEyeIcon(bool isObscured, VoidCallback onTap, Color iconColor) {
    return IconButton(
      icon: Icon(
        isObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        color: iconColor,
        size: 20,
      ),
      onPressed: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final inputBgColor = isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle;
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Icon(Icons.mark_email_read_outlined, color: AppColors.primary, size: 48),
            const SizedBox(height: 20),
            Text(
              'Ingresa el código',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 8),
            Text(
              'Enviamos un código de 6 dígitos a ${widget.email}. Ingrésalo junto con tu nueva contraseña.',
              style: TextStyle(fontSize: 14, color: subtitleColor),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, letterSpacing: 8, color: textColor),
              decoration: const InputDecoration(
                counterText: '',
                hintText: '000000',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Nueva contraseña',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: subtitleColor),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: TextStyle(color: textColor, fontSize: 14),
              decoration: InputDecoration(
                hintText: '••••••••',
                hintStyle: TextStyle(color: subtitleColor.withOpacity(0.5), fontSize: 14),
                prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary, size: 20),
                suffixIcon: _buildEyeIcon(
                  _obscurePassword,
                  () => setState(() => _obscurePassword = !_obscurePassword),
                  subtitleColor,
                ),
                filled: true,
                fillColor: inputBgColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Mín. 6 caracteres, mayúscula, minúscula, número y carácter especial',
              style: TextStyle(fontSize: 11, color: subtitleColor),
            ),
            const SizedBox(height: 16),
            Text(
              'Confirmar contraseña',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: subtitleColor),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _confirmController,
              obscureText: _obscureConfirm,
              style: TextStyle(color: textColor, fontSize: 14),
              decoration: InputDecoration(
                hintText: '••••••••',
                hintStyle: TextStyle(color: subtitleColor.withOpacity(0.5), fontSize: 14),
                prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary, size: 20),
                suffixIcon: _buildEyeIcon(
                  _obscureConfirm,
                  () => setState(() => _obscureConfirm = !_obscureConfirm),
                  subtitleColor,
                ),
                filled: true,
                fillColor: inputBgColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: auth.isLoading ? null : _handleReset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: auth.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Cambiar contraseña',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
