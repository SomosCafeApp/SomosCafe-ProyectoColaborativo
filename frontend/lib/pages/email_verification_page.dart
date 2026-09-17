import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';

class EmailVerificationPage extends StatefulWidget {
  final String email;
  final VoidCallback onVerified;

  const EmailVerificationPage({
    super.key,
    required this.email,
    required this.onVerified,
  });

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    final auth = context.read<AuthProvider>();
    final code = _codeController.text.trim();

    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa el código de 6 dígitos')),
      );
      return;
    }

    final success = await auth.verifyEmail(widget.email, code);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Correo verificado. Ya puedes iniciar sesión.')),
      );
      widget.onVerified();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Código inválido')),
      );
    }
  }

  Future<void> _handleResend() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.resendVerificationCode(widget.email);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Nuevo código enviado a ${widget.email}'
              : (auth.errorMessage ?? 'No se pudo reenviar el código'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();

    // Asignación con AppColors centralizado
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final circleBgColor = isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle;
    final circleIconColor = AppColors.primary;

    final inputBgColor = isDark ? AppColors.darkSurface : AppColors.lightSurfaceSubtle;
    final inputBorderColor = isDark ? AppColors.darkSurfaceSubtle : const Color(0xFFE5DDD5);

    final buttonBgColor =   AppColors.primary;
    final buttonTextColor = isDark ? AppColors.darkBackground : Colors.white;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // Icono en círculo
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: circleBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.mark_email_read_outlined,
                  color: circleIconColor,
                  size: 42,
                ),
              ),
              const SizedBox(height: 28),

              // Título
              Text(
                'Verifica tu correo',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),

              // Subtítulo con correo dinámico
              Text(
                'Hemos enviado un código de 6 dígitos a:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: subtitleColor),
              ),
              const SizedBox(height: 4),
              Text(
                widget.email,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 32),

              // Campo de texto del código
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: textColor,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'Código de verificación',
                  hintStyle: TextStyle(
                    color: subtitleColor.withOpacity(0.7),
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: inputBgColor,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: inputBorderColor, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: buttonBgColor, width: 1.2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Botón principal
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _handleVerify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonBgColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: auth.isLoading
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: buttonTextColor,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Verificar y Crear Cuenta',
                          style: TextStyle(
                            color: buttonTextColor,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Texto interactivo de reenvío
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(fontSize: 13, color: subtitleColor),
                  children: [
                    const TextSpan(text: '¿No recibiste el código? '),
                    TextSpan(
                      text: 'Reenviar',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: auth.isLoading ? subtitleColor : textColor,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = auth.isLoading ? null : _handleResend,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}