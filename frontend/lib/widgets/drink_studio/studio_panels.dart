import 'package:flutter/material.dart';

import '../../models/drink_studio_stage.dart';
import 'latte_art_panel.dart';
import 'stage_basic_panels.dart';
import 'toppings_panel.dart';

/// Panel de cada sección (el resultado final tiene su propia pantalla).
Widget buildStudioPanel(StudioStep step) => switch (step) {
      StudioStep.size => const SizePanel(),
      StudioStep.base => const BasePanel(),
      StudioStep.milk => const MilkPanel(),
      StudioStep.art => const LatteArtPanel(),
      StudioStep.toppings => const ToppingsPanel(),
      StudioStep.result => const SizedBox.shrink(),
    };
