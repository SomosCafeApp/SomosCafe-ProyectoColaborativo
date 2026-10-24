import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/drink_studio_provider.dart';
import 'cup_stage.dart';
import 'milk_badge.dart';
import 'mix_bar.dart';
import 'studio_colors.dart';

/// Zona de juego: el vaso en vivo, la barra de mezcla, la ilustración
/// de la leche y la etiqueta con tamaño y temperatura.
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
        Positioned.fill(child: CupStage(snapshot: s.snapshot, pourKind: s.pourKind, pourTick: s.pourTick)),
        Positioned(
          right: 10,
          top: 14,
          bottom: 14,
          child: const MixBar(),
        ),
        Align(
          alignment: const Alignment(0, -0.92),
          child: MilkBadge(tick: s.milkPopTick, name: s.milkPopName),
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
