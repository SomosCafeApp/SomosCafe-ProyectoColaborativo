import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../animations/press_scale.dart';
import '../../providers/drink_studio_provider.dart';
import 'latte_art_shapes.dart';
import 'option_card.dart';
import 'studio_colors.dart';

/// Arte latte (opcional): tres diseños con vista previa. Al elegir uno
/// la jarrita vierte la leche y el dibujo se forma sobre el café.
class LatteArtPanel extends StatelessWidget {
  const LatteArtPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<DrinkStudioProvider>();
    final dark = Theme.of(context).brightness == Brightness.dark;
    final designs = s.options!.latteArtDesigns;

    Widget card({required Widget preview, required String label, required bool selected, required VoidCallback onTap}) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: PressScale(
              onTap: onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? StudioColors.primary.withValues(alpha: dark ? 0.3 : 0.14) : StudioColors.soft(dark),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: selected ? StudioColors.primary : Colors.transparent, width: 2),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 58, width: 58, child: preview),
                    const SizedBox(height: 5),
                    Text(label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: StudioColors.text(dark))),
                  ],
                ),
              ),
            ),
          ),
        );

    return StagePanel(
      title: '¿Quieres arte latte?',
      hint: 'Es opcional y no cuesta extra. Elige un diseño y mira cómo se vierte la leche.',
      child: Column(
        children: [
          Row(
            children: [
              card(
                preview: Icon(Icons.block_rounded, size: 34, color: StudioColors.muted(dark)),
                label: 'Sin arte',
                selected: s.latteArt.isEmpty,
                onTap: () {
                  HapticFeedback.selectionClick();
                  if (s.latteArt.isNotEmpty) s.setLatteArt(s.latteArt);
                },
              ),
              for (final d in designs)
                card(
                  preview: LatteArtDisc(design: d, size: 58),
                  label: d,
                  selected: s.latteArt == d,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    if (s.latteArt != d) s.setLatteArt(d);
                  },
                ),
            ],
          ),
          if (s.latteArt.isNotEmpty)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: s.replayArt,
                icon: const Icon(Icons.replay_rounded, size: 18),
                label: const Text('Volver a verter'),
                style: TextButton.styleFrom(foregroundColor: StudioColors.primary),
              ),
            ),
        ],
      ),
    );
  }
}
