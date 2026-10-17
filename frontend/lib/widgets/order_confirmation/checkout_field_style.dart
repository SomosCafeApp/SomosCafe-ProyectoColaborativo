import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Estilo de los campos de texto del checkout: fondo de tarjeta, bordes
/// redondeados suaves, icono y etiqueta flotante en el color de marca,
/// y borde de marca al enfocar.
InputDecoration checkoutFieldDecoration(
  BuildContext context, {
  required String label,
  required IconData icon,
  String? hint,
  bool showCounter = false,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  final borderColor = isDark ? Colors.white12 : const Color(0xFFE6E0D8);
  const errorColor = Color(0xFFE53935);

  OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color, width: width),
      );

  return InputDecoration(
    labelText: label,
    hintText: hint,
    labelStyle: TextStyle(color: subtitleColor, fontSize: 14),
    floatingLabelStyle: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
    hintStyle: TextStyle(color: subtitleColor.withAlpha(150), fontSize: 14),
    prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
    filled: true,
    fillColor: isDark ? AppColors.darkSurface : Colors.white,
    counterText: showCounter ? null : '',
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: border(borderColor, 1),
    enabledBorder: border(borderColor, 1),
    focusedBorder: border(AppColors.primary, 1.6),
    errorBorder: border(errorColor, 1),
    focusedErrorBorder: border(errorColor, 1.6),
  );
}
