import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';

class LoginFormCard extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const LoginFormCard({
    super.key,
    required this.emailController,
    required this.passwordController,
  });

  @override
  State<LoginFormCard> createState() => _LoginFormCardState();
}

class _LoginFormCardState extends State<LoginFormCard> {
  bool _rememberMe = false;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final inputBgColor = isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Correo electrónico',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: subtitleColor,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: widget.emailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(color: textColor, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'tu@email.com',
              hintStyle: TextStyle(color: subtitleColor.withOpacity(0.5), fontSize: 14),
              prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary, size: 20),
              filled: true,
              fillColor: inputBgColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Contraseña',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: subtitleColor,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: widget.passwordController,
            obscureText: _obscurePassword,
            style: TextStyle(color: textColor, fontSize: 14),
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: TextStyle(color: subtitleColor.withOpacity(0.5), fontSize: 14),
              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: subtitleColor,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
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
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: _rememberMe,
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Recordarme',
                    style: TextStyle(fontSize: 13, color: subtitleColor),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  '¿Olvidaste tu contraseña?',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                final email = widget.emailController.text.trim();
                final password = widget.passwordController.text.trim();

                if (email.isNotEmpty && password.length >= 6) {
                  context.read<AuthProvider>().login(email, password);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ingresa un correo y contraseña (min 6 caracteres)'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.login, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Iniciar Sesión',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
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
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.g_mobiledata, color: Colors.red, size: 24),
                ),
                const SizedBox(width: 10),
                Text(
                  'Google',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
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