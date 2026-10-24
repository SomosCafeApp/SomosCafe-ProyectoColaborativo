import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/drink_studio_provider.dart';
import 'latte_art_shapes.dart';
import 'option_card.dart';
import 'studio_colors.dart';
import '../../animations/press_scale.dart';

/// Latte art: tres diseños predefinidos. Al elegir uno se ve de
/// inmediato sobre el café del vaso (vista previa en tiempo real).
class LatteArtPanel extends StatelessWidget {
  const LatteArtPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<DrinkStudioProvider>();
    final dark = Theme.of(context).brightness == Brightness.dark;
    final designs = s.options!.latteArtDesigns;
    return StagePanel(
      title: 'Decora tu espuma',
      hint: 'Elige un diseño; vuelve a tocarlo para quitarlo. Es decoración, no cuesta extra.',
      child: Row(
        children: [
          for (final d in designs)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: PressScale(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    s.setLatteArt(d);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: s.latteArt == d ? StudioColors.primary.withValues(alpha: dark ? 0.3 : 0.14) : StudioColors.soft(dark),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: s.latteArt == d ? StudioColors.primary : Colors.transparent, width: 1.6),
                    ),
                    child: Column(
                      children: [
                        LatteArtDisc(design: d, size: 64),
                        const SizedBox(height: 6),
                        Text(d, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: StudioColors.text(dark))),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
