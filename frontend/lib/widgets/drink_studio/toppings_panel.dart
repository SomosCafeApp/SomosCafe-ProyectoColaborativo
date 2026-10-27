import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../animations/press_scale.dart';
import '../../core/utils/money_format.dart';
import '../../providers/drink_studio_provider.dart';
import 'option_card.dart';
import 'studio_colors.dart';
import 'topping_icon.dart';

/// Toppings (y jarabes / endulzantes si el negocio los carga). La taza
/// se ve desde arriba y cada ingrediente cae sobre la superficie.
class ToppingsPanel extends StatelessWidget {
  const ToppingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<DrinkStudioProvider>();
    final o = s.options!;
    final hasCream = s.toppings.any((t) => t.toLowerCase().contains('crema'));
    final note = s.latteArt.isNotEmpty && hasCream
        ? 'Tu crema va en el borde para dejar a la vista el arte latte.'
        : 'Toca para añadir o quitar. Cada ingrediente se ve en tu bebida al instante.';

    return StagePanel(
      title: 'Decora con toppings',
      hint: note,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (o.toppings.isNotEmpty) _group(context, s, o.toppings, s.toppings, s.toggleTopping, null),
          if (o.hasSyrups) ...[
            const _Label('Jarabes'),
            _group(context, s, o.syrups, s.syrups, s.toggleSyrup, o.maxSyrups),
          ],
          if (o.hasSweeteners) ...[
            const _Label('Endulzantes'),
            _group(context, s, o.sweeteners, s.sweeteners, s.toggleSweetener, o.maxSweeteners),
          ],
        ],
      ),
    );
  }

  Widget _group(BuildContext context, DrinkStudioProvider s, Map<String, double> prices, Set<String> selected, bool Function(String) onToggle, int? max) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, box) {
        final w = (box.maxWidth - 20) / 3;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final e in prices.entries)
              PressScale(
                onTap: () {
                  HapticFeedback.selectionClick();
                  if (!onToggle(e.key)) {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(SnackBar(content: Text('Máximo $max opciones en esta categoría')));
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutCubic,
                  width: w,
                  padding: const EdgeInsets.fromLTRB(4, 10, 4, 8),
                  decoration: BoxDecoration(
                    color: selected.contains(e.key) ? StudioColors.primary.withValues(alpha: dark ? 0.3 : 0.14) : StudioColors.soft(dark),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: selected.contains(e.key) ? StudioColors.primary : Colors.transparent, width: 2),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Column(
                          children: [
                            ToppingIcon(name: e.key, size: 42),
                            const SizedBox(height: 4),
                            Text(e.key, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: StudioColors.text(dark))),
                            Text(formatExtra(e.value), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: StudioColors.primary)),
                          ],
                        ),
                      ),
                      Positioned(
                        top: -4,
                        right: 2,
                        child: AnimatedScale(
                          scale: selected.contains(e.key) ? 1 : 0,
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutBack,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(color: StudioColors.primary, shape: BoxShape.circle),
                            child: const Icon(Icons.check_rounded, size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 8),
      child: Text(text, style: TextStyle(fontWeight: FontWeight.w800, color: StudioColors.text(dark))),
    );
  }
}
