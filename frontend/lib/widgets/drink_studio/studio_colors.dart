import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Paleta del estudio de bebidas: tonos café, crema y beige derivados
/// de la identidad de SomosCafe (AppColors.primary).
class StudioColors {
  StudioColors._();

  static const Color ink = Color(0xFF5A3A24);
  static const Color roast = Color(0xFF4A2C1B);
  static const Color latte = Color(0xFFD9B88F);
  static const Color cream = Color(0xFFFFF6E6);
  static const Color beige = Color(0xFFF2E3CC);
  static const Color caramel = Color(0xFFD08A2E);
  static const Color primary = AppColors.primary;

  /// Acentos cálidos para jarabes y endulzantes (solo decoración).
  static const List<Color> accents = [
    Color(0xFFD08A2E),
    Color(0xFFB5543C),
    Color(0xFF8C5C2B),
    Color(0xFFE0B05A),
    Color(0xFFA8685A),
  ];

  static Color accentFor(String name) {
    var h = 0;
    for (final c in name.codeUnits) {
      h = (h * 31 + c) & 0xFFFF;
    }
    return accents[h % accents.length];
  }

  /// Crema batida: luz, tono medio y sombras (los usa el pintor de toppings).
  static const Color cream1 = Color(0xFFFFFEFA);
  static const Color cream2 = Color(0xFFFFF4E0);
  static const Color cream3 = Color(0xFFEAD3AE);
  static const Color cream4 = Color(0xFFD2B084);

  /// Degradado de marca para botones principales y cabeceras.
  static const LinearGradient brand = LinearGradient(
    colors: [Color(0xFFB88257), AppColors.primary, Color(0xFF7E5230)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Color panel(bool dark) => dark ? AppColors.darkSurface : AppColors.lightSurface;
  static Color soft(bool dark) => dark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle;
  static Color text(bool dark) => dark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
  static Color muted(bool dark) => dark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
}
