import 'package:flutter/material.dart';

/// Secciones del estudio de bebidas, SIEMPRE en este orden: temperatura,
/// base (tamaño y espresso), leche, arte latte, toppings y presentación
/// final. El arte latte solo aparece en bebidas calientes con espuma.
enum StudioStep { temperature, base, milk, art, toppings, result }

/// Cómo se juega el arte latte: libre (sin objetivos ni puntos) o
/// desafío (un diseño que completar, con puntuación opcional).
enum StudioMode { free, challenge }

extension StudioStepInfo on StudioStep {
  String get label => switch (this) {
        StudioStep.temperature => 'Temperatura',
        StudioStep.base => 'Base',
        StudioStep.milk => 'Leche',
        StudioStep.art => 'Arte latte',
        StudioStep.toppings => 'Toppings',
        StudioStep.result => 'Resultado',
      };

  IconData get icon => switch (this) {
        StudioStep.temperature => Icons.thermostat_rounded,
        StudioStep.base => Icons.coffee_rounded,
        StudioStep.milk => Icons.water_drop_rounded,
        StudioStep.art => Icons.brush_rounded,
        StudioStep.toppings => Icons.auto_awesome_rounded,
        StudioStep.result => Icons.check_circle_rounded,
      };
}
