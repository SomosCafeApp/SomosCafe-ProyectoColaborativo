import 'package:flutter/material.dart';

import '../../models/drink_studio_stage.dart';
import '../../providers/drink_studio_provider.dart';
import 'latte_art_panel.dart';
import 'stage_basic_panels.dart';
import 'stage_pairing_panel.dart';
import 'stage_pick_panel.dart';

/// Panel de cada pestaña. Los que eligen opciones reciben los
/// catálogos REALES del backend.
Widget buildStudioPanel(StudioStage stage, DrinkStudioProvider s) {
  final o = s.options!;
  return switch (stage) {
    StudioStage.size => const SizePanel(),
    StudioStage.base => const BasePanel(),
    StudioStage.milk => const MilkPanel(),
    StudioStage.syrups => PickPanel(
        title: 'Dale un toque de jarabe',
        hint: 'Toca para añadir jarabe a tu bebida.',
        prices: o.syrups,
        selected: s.syrups,
        onToggle: s.toggleSyrup,
        icon: Icons.opacity_rounded,
        max: o.maxSyrups,
      ),
    StudioStage.sweeteners => PickPanel(
        title: 'Endúlzala a tu gusto',
        hint: 'Toca para espolvorear el endulzante.',
        prices: o.sweeteners,
        selected: s.sweeteners,
        onToggle: s.toggleSweetener,
        icon: Icons.grain_rounded,
        max: o.maxSweeteners,
      ),
    StudioStage.toppings => PickPanel(
        title: 'Decora con toppings',
        hint: 'Toca para decorar la superficie.',
        prices: o.toppings,
        selected: s.toppings,
        onToggle: s.toggleTopping,
        icon: Icons.auto_awesome_rounded,
      ),
    StudioStage.latteArt => const LatteArtPanel(),
    StudioStage.pairing => const PairingPanel(),
  };
}
