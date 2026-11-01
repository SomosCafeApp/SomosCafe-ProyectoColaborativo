import 'package:flutter/material.dart';

import '../../models/drink_studio_stage.dart';
import 'latte_art_panel.dart';
import 'summary_overlay.dart';
import 'stage_basic_panels.dart';
import 'toppings_panel.dart';

/// Panel de cada sección; el resultado es la presentación final.
Widget buildStudioPanel(StudioStep step) => switch (step) {
      StudioStep.temperature => const TemperaturePanel(),
      StudioStep.base => const BasePanel(),
      StudioStep.milk => const MilkPanel(),
      StudioStep.art => const LatteArtPanel(),
      StudioStep.toppings => const ToppingsPanel(),
      StudioStep.result => const SummaryOverlay(),
    };
