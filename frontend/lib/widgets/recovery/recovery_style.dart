import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Degradado café usado en el header y en el botón de recuperación.
const LinearGradient recoveryGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF8F6339), AppColors.primary, Color(0xFFA67A4E)],
);

/// Decoración de los campos: relleno suave, bordes redondeados e icono café.
InputDecoration recoveryInputDecoration(
  BuildContext context, {
  required String hint,
  required IconData icon,
  Widget? suffix,
  TextStyle? hintStyle,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final subtitleColor =
      isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  final inputBg =
      isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle;

  return InputDecoration(
    hintText: hint,
    hintStyle: (hintStyle ?? const TextStyle(fontSize: 14))
        .copyWith(color: subtitleColor.withValues(alpha: 0.5)),
    prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
    suffixIcon: suffix,
    counterText: '',
    filled: true,
    fillColor: inputBg,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 14),
  );
}
