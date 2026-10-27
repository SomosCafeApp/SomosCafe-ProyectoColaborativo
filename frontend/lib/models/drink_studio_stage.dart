import 'package:flutter/material.dart';

/// Secciones del estudio de bebidas, SIEMPRE en este orden. El arte
/// latte solo aparece en bebidas calientes con espuma de leche.
enum StudioStep { size, base, milk, art, toppings, result }

/// Cómo se juega el arte latte: libre (sin objetivos ni puntos) o
/// desafío (un diseño que completar, con puntuación opcional).
enum StudioMode { free, challenge }

extension StudioStepInfo on StudioStep {
  String get label => switch (this) {
        StudioStep.size => 'Tamaño',
        StudioStep.base => 'Base',
        StudioStep.milk => 'Leche',
        StudioStep.art => 'Arte latte',
        StudioStep.toppings => 'Toppings',
        StudioStep.result => 'Resultado',
      };

  IconData get icon => switch (this) {
        StudioStep.size => Icons.straighten_rounded,
        StudioStep.base => Icons.thermostat_rounded,
        StudioStep.milk => Icons.water_drop_rounded,
        StudioStep.art => Icons.brush_rounded,
        StudioStep.toppings => Icons.auto_awesome_rounded,
        StudioStep.result => Icons.check_circle_rounded,
      };
}
