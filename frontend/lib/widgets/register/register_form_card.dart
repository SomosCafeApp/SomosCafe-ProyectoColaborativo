import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'custom_text_field.dart';

class RegisterFormCard extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;
  final VoidCallback onRegister;
  const RegisterFormCard({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
    required this.onRegister,
  });
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
            label: 'Nombre completo',
            hintText: 'Juan Pérez',
            controller: nameController,
            prefixIcon: Icons.person_outline,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Correo electrónico',
            hintText: 'user@example.com',
            controller: emailController,
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Contraseña',
            hintText: '••••••••',
            controller: passwordController,
            prefixIcon: Icons.lock_outline,
            obscureText: obscurePassword,
            suffixIcon: _buildEyeIcon(
              obscurePassword,
              onTogglePassword,
              subtitleColor,
            ),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Confirmar contraseña',
            hintText: '••••••••',
            controller: confirmPasswordController,
            prefixIcon: Icons.lock_outline,
            obscureText: obscureConfirmPassword,
            suffixIcon: _buildEyeIcon(
              obscureConfirmPassword,
              onToggleConfirmPassword,
              subtitleColor,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onRegister,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              elevation: 0,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Row(
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
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              backgroundColor: inputBgColor,
              side: BorderSide(color: subtitleColor.withOpacity(0.2)),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
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
