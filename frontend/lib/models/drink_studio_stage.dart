import 'package:flutter/material.dart';

/// Pestañas de la bandeja de control del estudio de bebidas. Todas
/// viven en la misma pantalla; cuáles aparecen depende del tipo de
/// bebida y de los datos reales disponibles (ver `DrinkStudioProvider.tabs`).
enum StudioStage { size, base, milk, syrups, sweeteners, toppings, latteArt, pairing }

extension StudioStageInfo on StudioStage {
  String get label => switch (this) {
        StudioStage.size => 'Tamaño',
        StudioStage.base => 'Base',
        StudioStage.milk => 'Leche',
        StudioStage.syrups => 'Jarabes',
        StudioStage.sweeteners => 'Endulzar',
        StudioStage.toppings => 'Toppings',
        StudioStage.latteArt => 'Latte art',
        StudioStage.pairing => 'Acompañar',
      };

  IconData get icon => switch (this) {
        StudioStage.size => Icons.straighten_rounded,
        StudioStage.base => Icons.coffee_maker_rounded,
        StudioStage.milk => Icons.water_drop_rounded,
        StudioStage.syrups => Icons.opacity_rounded,
        StudioStage.sweeteners => Icons.grain_rounded,
        StudioStage.toppings => Icons.auto_awesome_rounded,
        StudioStage.latteArt => Icons.brush_rounded,
        StudioStage.pairing => Icons.cake_rounded,
      };
}
