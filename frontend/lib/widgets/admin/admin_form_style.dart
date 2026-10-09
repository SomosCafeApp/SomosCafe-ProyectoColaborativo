import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Estilo común de los formularios del panel admin (mismo look que el
/// formulario de direcciones): campos redondeados con fondo suave.
class AdminFormStyle {
  final Color textColor;
  final Color subtitleColor;
  final Color fill;
  final Color cardColor;
  final bool isDark;

  const AdminFormStyle._({
    required this.textColor,
    required this.subtitleColor,
    required this.fill,
    required this.cardColor,
    required this.isDark,
  });

  factory AdminFormStyle.of(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return AdminFormStyle._(
      textColor: theme.colorScheme.onSurface,
      subtitleColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
      fill: isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle,
      cardColor: theme.cardTheme.color ?? (isDark ? AppColors.darkSurface : AppColors.lightSurface),
      isDark: isDark,
    );
  }

  InputDecoration decoration(String hint, {String? prefix, String? suffix, double radius = 30}) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: subtitleColor.withAlpha(180), fontSize: 14),
        prefixText: prefix,
        suffixText: suffix,
        filled: true,
        fillColor: fill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(radius), borderSide: BorderSide.none),
      );

  BoxDecoration get cardDecoration => BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(isDark ? 50 : 10), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      );
}

/// Etiqueta de un campo del formulario.
class AdminFieldLabel extends StatelessWidget {
  final String text;

  const AdminFieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface),
        ),
      );
}

/// Encabezado del formulario con título y botón de cerrar.
class AdminFormHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onClose;

  const AdminFormHeader({super.key, required this.title, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final style = AdminFormStyle.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: style.textColor)),
        GestureDetector(
          onTap: onClose,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: style.fill, shape: BoxShape.circle),
            child: Icon(Icons.close, size: 16, color: style.subtitleColor),
          ),
        ),
      ],
    );
  }
}
