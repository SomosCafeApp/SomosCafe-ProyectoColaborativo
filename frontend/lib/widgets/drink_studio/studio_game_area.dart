import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/drink_studio_stage.dart';
import '../../providers/drink_studio_provider.dart';
import 'cup_stage.dart';
import 'milk_badge.dart';
import 'studio_colors.dart';

/// Zona de juego: el vaso en vivo (de lado, inclinado o desde arriba
/// según la sección), la ilustración de la leche y la etiqueta con
/// tamaño y temperatura.
class StudioGameArea extends StatelessWidget {
  const StudioGameArea({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<DrinkStudioProvider>();
    final dark = Theme.of(context).brightness == Brightness.dark;
    final oz = s.ounces;
    final label = '${s.size}${oz != null ? ' · $oz oz' : ''} · ${s.type}';

    return Stack(
      children: [
        Positioned.fill(
          child: CupStage(
            snapshot: s.snapshot,
            view: s.view,
            pourKind: s.pourKind,
            pourTick: s.pourTick,
            transition: s.transition,
            transitionTick: s.transitionTick,
            transitionDir: s.transitionDir,
            artTick: s.artTick,
            ambient: s.stepIndex >= 1,
          ),
        ),
        Align(
          alignment: const Alignment(0, -0.8),
          child: MilkBadge(tick: s.milkPopTick, name: s.step == StudioStep.milk ? s.milkPopName : ''),
        ),
        Positioned(
          left: 14,
          bottom: 10,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Container(
              key: ValueKey(label),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: StudioColors.panel(dark).withValues(alpha: 0.85), borderRadius: BorderRadius.circular(14), border: Border.all(color: StudioColors.primary.withValues(alpha: 0.4))),
              child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: StudioColors.text(dark))),
            ),
          ),
        ),
      ],
    );
  }
}
