import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../services/google_auth_service.dart';
import '../../providers/auth_provider.dart';
import 'custom_text_field.dart';

class RegisterFormCard extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final bool isLoading;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;
  final VoidCallback onRegister;

  const RegisterFormCard({
    super.key,
    required this.nameController,
    required this.lastNameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
    required this.onRegister,
    this.isLoading = false,
  });

  @override
  State<RegisterFormCard> createState() => _RegisterFormCardState();
}

class _RegisterFormCardState extends State<RegisterFormCard> {
  bool _isGoogleLoading = false;

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

  Future<void> _handleGoogleSignUp() async {
    setState(() => _isGoogleLoading = true);
    try {
      final idToken = await GoogleAuthService.signInAndGetIdToken();
      if (idToken == null) return; // cancelado por el usuario

      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      final success = await auth.loginWithGoogle(idToken);

      if (!mounted) return;
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(auth.errorMessage ?? 'No se pudo continuar con Google')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al conectar con Google')),
      );
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final inputBgColor = isDark
        ? AppColors.darkSurfaceSubtle
        : AppColors.lightSurfaceSubtle;
    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final subtitleColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          CustomTextField(
            label: 'Nombre',
            hintText: 'Juan',
            controller: widget.nameController,
            prefixIcon: Icons.person_outline,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Apellido',
            hintText: 'Pérez',
            controller: widget.lastNameController,
            prefixIcon: Icons.person_outline,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Correo electrónico',
            hintText: 'user@example.com',
            controller: widget.emailController,
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Contraseña',
            hintText: '••••••••',
            controller: widget.passwordController,
            prefixIcon: Icons.lock_outline,
            obscureText: widget.obscurePassword,
            suffixIcon: _buildEyeIcon(
              widget.obscurePassword,
              widget.onTogglePassword,
              subtitleColor,
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Mín. 6 caracteres, mayúscula, minúscula, número y carácter especial',
              style: TextStyle(fontSize: 9.4, color: subtitleColor),
            ),
          ),
          const SizedBox(height: 12),
          CustomTextField(
            label: 'Confirmar contraseña',
            hintText: '••••••••',
            controller: widget.confirmPasswordController,
            prefixIcon: Icons.lock_outline,
            obscureText: widget.obscureConfirmPassword,
            suffixIcon: _buildEyeIcon(
              widget.obscureConfirmPassword,
              widget.onToggleConfirmPassword,
              subtitleColor,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: widget.isLoading ? null : widget.onRegister,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              elevation: 0,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: widget.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_add_outlined, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Crear cuenta',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: Divider(color: subtitleColor.withOpacity(0.2))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'O continúa con',
                  style: TextStyle(fontSize: 12, color: subtitleColor),
                ),
              ),
              Expanded(child: Divider(color: subtitleColor.withOpacity(0.2))),
            ],
          ),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: _isGoogleLoading ? null : _handleGoogleSignUp,
            style: OutlinedButton.styleFrom(
              backgroundColor: inputBgColor,
              side: BorderSide(color: subtitleColor.withOpacity(0.2)),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isGoogleLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: textColor),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/icons/google.png',
                        height: 18,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.g_mobiledata,
                          color: Colors.red,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Google',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
