import 'package:flutter/material.dart';

import '../../animations/soft_page_transitions.dart';
import '../constants/app_colors.dart';
import 'app_tokens.dart';

/// Tema único de SOMOS CAFÉ. Claro y oscuro salen de la MISMA función, así
/// radios, elevaciones, botones, diálogos y hojas inferiores siguen las
/// reglas de [AppRadius], [AppSizes] y [AppDurations] y no se desalinean.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => _build(
        brightness: Brightness.light,
        background: AppColors.lightBackground,
        surface: AppColors.lightSurface,
        textPrimary: AppColors.lightTextPrimary,
        textSecondary: AppColors.lightTextSecondary,
        scheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.accentYellow,
          surface: AppColors.lightSurface,
          onPrimary: Colors.white,
          onSurface: AppColors.lightTextPrimary,
        ),
      );

  static ThemeData get darkTheme => _build(
        brightness: Brightness.dark,
        background: AppColors.darkBackground,
        surface: AppColors.darkSurface,
        textPrimary: AppColors.darkTextPrimary,
        textSecondary: AppColors.darkTextSecondary,
        scheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.accentYellow,
          surface: AppColors.darkSurface,
          onPrimary: Colors.white,
          onSurface: AppColors.darkTextPrimary,
        ),
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color textPrimary,
    required Color textSecondary,
    required ColorScheme scheme,
  }) {
    final buttonShape = WidgetStatePropertyAll<OutlinedBorder>(RoundedRectangleBorder(borderRadius: AppRadius.control));
    const minSize = WidgetStatePropertyAll<Size>(Size(64, AppSizes.minTap));

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: background,
      pageTransitionsTheme: AppMotion.pageTransitions,
      colorScheme: scheme,

      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      ),

      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: surface,
        titleTextStyle: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
        contentTextStyle: TextStyle(color: textSecondary, fontSize: 13),
      ),

      // Hojas inferiores: esquinas superiores redondeadas y asa visible.
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        showDragHandle: true,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.sheet),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.primary,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
        actionTextColor: AppColors.accentYellow,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),

      // Botones: misma forma y un alto táctil mínimo de 48 dp.
      filledButtonTheme: FilledButtonThemeData(style: ButtonStyle(shape: buttonShape, minimumSize: minSize)),
      elevatedButtonTheme: ElevatedButtonThemeData(style: ButtonStyle(shape: buttonShape, minimumSize: minSize)),
      outlinedButtonTheme: OutlinedButtonThemeData(style: ButtonStyle(shape: buttonShape, minimumSize: minSize)),

      // Los indicadores genéricos que queden (p. ej. dentro de un botón)
      // usan el color de la marca.
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.primary),
    );
  }
}
