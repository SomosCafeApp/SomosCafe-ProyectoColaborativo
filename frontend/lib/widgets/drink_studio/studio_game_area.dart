import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/drink_studio_stage.dart';
import '../../providers/drink_studio_provider.dart';
import 'art_mini_preview.dart';
import 'art_overlays.dart';
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
          child: RepaintBoundary(
            key: s.artKey,
            child: CupStage(
              snapshot: s.snapshot,
              view: s.view,
              pourKind: s.pourKind,
              pourTick: s.pourTick,
              transition: s.transition,
              transitionTick: s.transitionTick,
              transitionDir: s.transitionDir,
              ambient: s.stepIndex >= 1,
              // El vertido solo existe en la etapa de arte (y solo en ella
              // se ve la silueta guía sobre el café).
              pour: s.step == StudioStep.art ? s.pour : null,
              interactive: s.artInteractive,
              bumpTick: s.stepDoneTick,
              lidOn: s.showSummary && !s.resultTop,
            ),
          ),
        ),
        if (s.showSummary)
          Positioned(
            left: 0,
            right: 0,
            bottom: 8,
            child: Center(
              child: _ViewToggle(top: s.resultTop, onChanged: s.setResultTop),
            ),
          ),
        if (s.step == StudioStep.art) ...[
          Align(
            alignment: const Alignment(0, -0.93),
            child: ArtCoachMark(pour: s.pour),
          ),
          Align(
            alignment: const Alignment(0, -0.7),
            child: ArtDoneBanner(pour: s.pour),
          ),
          Positioned(left: 12, top: 10, child: ArtMiniPreview(pour: s.pour)),
        ],
        // Cartón de leche que vierte sobre el café (se pinta con la misma
        // geometría del vaso para que el chorro caiga en la superficie).
        Positioned.fill(
          child: MilkPourOverlay(tick: s.milkPopTick, name: s.milkPopName, snapshot: s.snapshot),
        ),
        if (!s.showSummary)
          Positioned(
            left: 14,
            bottom: 10,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Container(
                key: ValueKey(label),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: StudioColors.panel(dark).withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: StudioColors.primary.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: StudioColors.text(dark),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Interruptor "Desde arriba / De lado" flotando sobre la bebida final.
class _ViewToggle extends StatelessWidget {
  const _ViewToggle({required this.top, required this.onChanged});
  final bool top;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    Widget item(String label, IconData icon, bool value) {
      final on = top == value;
      return Semantics(
        button: true,
        selected: on,
        label: label,
        child: GestureDetector(
          onTap: () => onChanged(value),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            constraints: const BoxConstraints(minHeight: 40),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: on ? StudioColors.brand : null,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: on ? Colors.white : StudioColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: on ? Colors.white : StudioColors.text(dark),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: StudioColors.panel(dark).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 8),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          item('Desde arriba', Icons.visibility_outlined, true),
          item('De lado', Icons.local_cafe_outlined, false),
        ],
      ),
    );
  }
}
