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
    final dark = brightness == Brightness.dark;
    final chipIdle = dark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle;
    final line = dark ? AppColors.darkBorder : const Color(0xFFEDE6DD);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: background,
      pageTransitionsTheme: AppMotion.pageTransitions,
      colorScheme: scheme,

      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
          side: dark ? const BorderSide(color: AppColors.darkBorder, width: 0.8) : BorderSide.none,
        ),
      ),

      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: dark ? AppColors.darkSurfaceRaised : surface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
        contentTextStyle: TextStyle(color: textSecondary, fontSize: 13),
      ),

      // Hojas inferiores: esquinas superiores redondeadas y asa visible.
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: dark ? AppColors.darkSurfaceRaised : surface,
        surfaceTintColor: Colors.transparent,
        dragHandleColor: dark ? AppColors.darkBorder : null,
        showDragHandle: true,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.sheet),
      ),

      // Chips / opciones seleccionables (categorías, filtros, tipos de
      // cupón…): SIN borde (antes M3 dibujaba un contorno claro/blanco),
      // fondo suave cuando no están seleccionados y color de marca al
      // seleccionarlos. Un solo estilo para toda la app.
      chipTheme: ChipThemeData(
        backgroundColor: chipIdle,
        selectedColor: AppColors.primary,
        disabledColor: chipIdle.withValues(alpha: 0.6),
        side: BorderSide.none,
        showCheckmark: false,
        elevation: 0,
        pressElevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        labelStyle: TextStyle(color: textSecondary, fontSize: 12.5, fontWeight: FontWeight.w600),
        secondaryLabelStyle: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700),
        iconTheme: IconThemeData(color: textSecondary, size: 18),
      ),

      // Segmented buttons (p. ej. modo del minijuego) con el mismo lenguaje.
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          side: const WidgetStatePropertyAll(BorderSide.none),
          backgroundColor: WidgetStateProperty.resolveWith((st) => st.contains(WidgetState.selected) ? AppColors.primary : chipIdle),
          foregroundColor: WidgetStateProperty.resolveWith((st) => st.contains(WidgetState.selected) ? Colors.white : textSecondary),
        ),
      ),

      dividerTheme: DividerThemeData(color: line, thickness: 1, space: 1),

      popupMenuTheme: PopupMenuThemeData(
        color: dark ? AppColors.darkSurfaceRaised : surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((st) => st.contains(WidgetState.selected) ? Colors.white : (dark ? AppColors.darkTextSecondary : Colors.white)),
        trackColor: WidgetStateProperty.resolveWith((st) => st.contains(WidgetState.selected) ? AppColors.primary : (dark ? AppColors.darkSurfaceRaised : const Color(0xFFD9D0C6))),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),

      listTileTheme: ListTileThemeData(iconColor: dark ? AppColors.darkAccent : AppColors.primary),

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
