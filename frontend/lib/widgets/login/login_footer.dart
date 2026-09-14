import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class LoginFooter extends StatelessWidget {
  final VoidCallback? onRegisterTap;

  const LoginFooter({
    super.key,
    this.onRegisterTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '¿No tienes una cuenta? ',
          style: TextStyle(color: subtitleColor, fontSize: 13),
        ),
        GestureDetector(
          onTap: onRegisterTap,
          child: const Text(
            'Regístrate aquí',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}