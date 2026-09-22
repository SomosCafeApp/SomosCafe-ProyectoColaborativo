import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';

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

    final passwordPolicy = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#%^&*()_+\-=\[\]{};:\x27"\\|,.<>/?]).{6,}$',
    );

    if (!passwordPolicy.hasMatch(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La contraseña debe tener mín. 6 caracteres, '
            'mayúscula, minúscula, número y carácter especial',
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
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contraseña actualizada. Inicia sesión de nuevo.'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Código inválido o expirado'),
        ),
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

    final auth = context.watch<AuthProvider>();

    final topBannerColor = AppColors.primary;

    final cardBgColor = isDark
        ? AppColors.darkSurfaceSubtle
        : AppColors.lightSurface;

    final inputBgColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightSurfaceSubtle;

    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;

    final subtitleColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    final buttonColor = AppColors.primary;

    final buttonTextColor = Colors.white;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: 330,
              decoration: BoxDecoration(color: topBannerColor),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(Icons.restore, color: Colors.white, size: 38),
                            Positioned(
                              right: 18,
                              bottom: 18,
                              child: Icon(
                                Icons.lock,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        'Nueva Contraseña',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        'Ingresa el código recibido y define tu nueva\ncontraseña',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),

                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              top: 50,
              left: 20,
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.25),
                radius: 18,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 18,
                  ),
                  onPressed: () {
                    Navigator.of(context).maybePop();
                  },
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(
                top: 280,
                left: 24,
                right: 24,
                bottom: 30,
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Código de verificación',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: subtitleColor,
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      enabled: !auth.isLoading,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        letterSpacing: 2,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: '000000',
                        hintStyle: TextStyle(
                          color: subtitleColor.withOpacity(0.5),
                          fontSize: 14,
                          letterSpacing: 2,
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 16, right: 12),
                          child: Text(
                            '#',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: subtitleColor,
                            ),
                          ),
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 0,
                          minHeight: 0,
                        ),
                        filled: true,
                        fillColor: inputBgColor,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'Nueva Contraseña',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: subtitleColor,
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      enabled: !auth.isLoading,
                      style: TextStyle(color: textColor, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        hintStyle: TextStyle(
                          color: subtitleColor.withOpacity(0.5),
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: subtitleColor,
                          size: 20,
                        ),
                        suffixIcon: _buildEyeIcon(_obscurePassword, () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        }, subtitleColor),
                        filled: true,
                        fillColor: inputBgColor,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'Confirmar Nueva Contraseña',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: subtitleColor,
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextField(
                      controller: _confirmController,
                      obscureText: _obscureConfirm,
                      enabled: !auth.isLoading,
                      style: TextStyle(color: textColor, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        hintStyle: TextStyle(
                          color: subtitleColor.withOpacity(0.5),
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: subtitleColor,
                          size: 20,
                        ),
                        suffixIcon: _buildEyeIcon(_obscureConfirm, () {
                          setState(() {
                            _obscureConfirm = !_obscureConfirm;
                          });
                        }, subtitleColor),
                        filled: true,
                        fillColor: inputBgColor,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: auth.isLoading ? null : _handleReset,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          disabledBackgroundColor: buttonColor.withOpacity(0.6),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
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
                                'Cambiar Contraseña',
                                style: TextStyle(
                                  color: buttonTextColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
