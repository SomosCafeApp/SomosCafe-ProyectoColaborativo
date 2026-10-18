import 'package:flutter/material.dart';

/// Tiempos y curvas comunes para que todo se mueva con el mismo "ritmo":
/// calmado, corto y sin rebotes exagerados.
class Motion {
  Motion._();

  static const Duration fast = Duration(milliseconds: 140);
  static const Duration base = Duration(milliseconds: 320);
  static const Duration slow = Duration(milliseconds: 500);

  static const Curve enter = Curves.easeOutCubic;

  /// true si el usuario pidió "reducir animaciones" en su sistema.
  static bool reduced(BuildContext context) =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false;
}
