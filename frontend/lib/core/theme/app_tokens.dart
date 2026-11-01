import 'package:flutter/material.dart';

/// Reglas de diseño compartidas por toda la app: espaciados, radios,
/// elevaciones, tamaños mínimos táctiles y tiempos de animación. Las
/// pantallas nuevas (y las que se revisen) deben usarlas en vez de
/// números sueltos para que todo respire igual.
class AppSpace {
  AppSpace._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  /// Margen horizontal estándar de una pantalla.
  static const double page = 16;

  /// Separación vertical entre secciones de una pantalla.
  static const double section = 24;

  static const EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: page);
}

class AppRadius {
  AppRadius._();

  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 28;
  static const double pill = 999;

  static BorderRadius get card => BorderRadius.circular(lg);
  static BorderRadius get control => BorderRadius.circular(md);
  static BorderRadius get sheet => const BorderRadius.vertical(top: Radius.circular(xl));
}

class AppElevation {
  AppElevation._();

  /// Sombra suave de tarjetas en reposo.
  static List<BoxShadow> card(bool dark) => [
        BoxShadow(color: Colors.black.withValues(alpha: dark ? 0.28 : 0.06), blurRadius: 14, offset: const Offset(0, 4)),
      ];

  /// Sombra de elementos que flotan (botones principales, paneles).
  static List<BoxShadow> raised(bool dark) => [
        BoxShadow(color: Colors.black.withValues(alpha: dark ? 0.4 : 0.12), blurRadius: 22, offset: const Offset(0, 8)),
      ];
}

class AppSizes {
  AppSizes._();

  /// Área táctil mínima recomendada (Material / WCAG).
  static const double minTap = 48;

  /// Alto de los botones principales.
  static const double button = 52;
}

class AppDurations {
  AppDurations._();

  static const Duration tap = Duration(milliseconds: 110);
  static const Duration fast = Duration(milliseconds: 160);
  static const Duration base = Duration(milliseconds: 260);
  static const Duration page = Duration(milliseconds: 320);
  static const Duration slow = Duration(milliseconds: 500);
}

/// Texto: jerarquía común (título, subtítulo, secundario, precio).
class AppText {
  AppText._();

  static TextStyle title(BuildContext c) => Theme.of(c).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.3);
  static TextStyle subtitle(BuildContext c) => Theme.of(c).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w700);
  static TextStyle body(BuildContext c) => Theme.of(c).textTheme.bodyMedium!;
  static TextStyle caption(BuildContext c) => Theme.of(c).textTheme.bodySmall!.copyWith(color: Theme.of(c).textTheme.bodySmall!.color?.withValues(alpha: 0.75));
  static TextStyle price(BuildContext c) => TextStyle(fontWeight: FontWeight.w900, color: Theme.of(c).colorScheme.primary);
}
