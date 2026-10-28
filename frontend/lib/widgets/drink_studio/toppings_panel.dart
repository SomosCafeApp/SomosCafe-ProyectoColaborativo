import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../animations/press_scale.dart';
import '../../core/utils/money_format.dart';
import '../../core/utils/studio_prefs.dart';
import '../../models/product_customization.dart';
import '../../providers/drink_studio_provider.dart';
import 'option_card.dart';
import 'studio_colors.dart';
import 'studio_ui.dart';
import 'sweetener_packet.dart';
import 'topping_icon.dart';

enum _Section { toppings, sweeteners, syrups }

/// Toppings, endulzantes (en sobrecitos) y jarabes. Cada topping
/// compatible con la bebida admite más porciones con los controles
/// + / −; cada porción extra suma \$300 y se refleja al instante.
class ToppingsPanel extends StatefulWidget {
  const ToppingsPanel({super.key});

  @override
  State<ToppingsPanel> createState() => _ToppingsPanelState();
}

class _ToppingsPanelState extends State<ToppingsPanel> {
  _Section _section = _Section.toppings;

  void _snack(String text) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) {
    final s = context.watch<DrinkStudioProvider>();
    final o = s.options!;
    final toppings = s.availableToppings;

    final sections = <_Section>[
      if (toppings.isNotEmpty) _Section.toppings,
      if (o.hasSweeteners) _Section.sweeteners,
      if (o.hasSyrups) _Section.syrups,
    ];
    final current = sections.contains(_section) ? _section : (sections.isEmpty ? _Section.toppings : sections.first);
    final hasCream = s.toppings.any((t) => t.toLowerCase().contains('crema'));

    final hint = switch (current) {
      _Section.toppings => s.latteArt.isNotEmpty && hasCream
          ? 'Tu crema va alrededor de la taza para dejar a la vista el arte latte.'
          : 'Toca para añadir y usa + / − para más porciones. Cada porción extra suma \$${o.toppingExtraPortionPrice.round()}.',
      _Section.sweeteners => 'Cada endulzante llega en su sobre, junto a tu bebida. Máximo ${o.maxSweeteners}.',
      _Section.syrups => 'Elige hasta ${o.maxSyrups} jarabes.',
    };

    return StagePanel(
      title: switch (current) {
        _Section.toppings => 'Decora con toppings',
        _Section.sweeteners => 'Endulza a tu gusto',
        _Section.syrups => 'Agrega un jarabe',
      },
      hint: hint,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (sections.length > 1) ...[
            StudioTabs(
              labels: [for (final x in sections) switch (x) { _Section.toppings => 'Toppings', _Section.sweeteners => 'Endulzantes', _Section.syrups => 'Jarabes' }],
              index: sections.indexOf(current),
              badges: {
                for (var i = 0; i < sections.length; i++)
                  i: switch (sections[i]) { _Section.toppings => s.toppings.length, _Section.sweeteners => s.sweeteners.length, _Section.syrups => s.syrups.length },
              },
              onChanged: (i) {
                StudioHaptics.select();
                setState(() => _section = sections[i]);
              },
            ),
            const SizedBox(height: 12),
          ],
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: KeyedSubtree(
              key: ValueKey(current),
              child: switch (current) {
                _Section.toppings => _toppingGrid(context, s, toppings),
                _Section.sweeteners => _sweetenerGrid(context, s),
                _Section.syrups => _syrupGrid(context, s),
              },
            ),
          ),
        ],
      ),
    );
  }

  // ───────────── Toppings con cantidad ─────────────

  Widget _toppingGrid(BuildContext context, DrinkStudioProvider s, Map<String, double> toppings) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final o = s.options!;
    return LayoutBuilder(
      builder: (context, box) {
        final w = (box.maxWidth - 10) / 2;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final e in toppings.entries)
              Builder(builder: (context) {
                final on = s.toppings.contains(e.key);
                final qty = s.toppingQuantity(e.key);
                final extras = qty > 1 ? qty - 1 : 0;
                return PressScale(
                  onTap: () {
                    StudioHaptics.select();
                    if (!on) s.toggleTopping(e.key);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOutCubic,
                    width: w,
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    decoration: StudioUi.choice(dark, selected: on),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ToppingIcon(name: e.key, size: 40),
                            const Spacer(),
                            AnimatedScale(
                              scale: on ? 1 : 0,
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOutBack,
                              child: GestureDetector(
                                onTap: () {
                                  StudioHaptics.select();
                                  s.toggleTopping(e.key);
                                },
                                child: const Icon(Icons.check_circle_rounded, size: 22, color: StudioColors.primary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(e.key, maxLines: 1, overflow: TextOverflow.ellipsis, style: StudioUi.name(dark)),
                        const SizedBox(height: 2),
                        Text(
                          on ? formatExtra(ProductCustomization.toppingLinePrice(e.value, qty)) : formatExtra(e.value),
                          style: StudioUi.price,
                        ),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          alignment: Alignment.topCenter,
                          child: on
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      QuantityPill(
                                        value: qty,
                                        compact: true,
                                        onMinus: () {
                                          StudioHaptics.select();
                                          s.changeToppingQuantity(e.key, -1);
                                        },
                                        onPlus: qty < o.maxToppingQuantity
                                            ? () {
                                                StudioHaptics.light();
                                                s.changeToppingQuantity(e.key, 1);
                                              }
                                            : null,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        extras > 0 ? '$extras extra × \$${o.toppingExtraPortionPrice.round()}' : qty >= o.maxToppingQuantity ? 'Máximo' : 'Incluye 1 porción',
                                        style: TextStyle(fontSize: 11, color: StudioColors.muted(dark)),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox(width: double.infinity),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        );
      },
    );
  }

  // ───────────── Endulzantes en sobre ─────────────

  Widget _sweetenerGrid(BuildContext context, DrinkStudioProvider s) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final o = s.options!;
    return LayoutBuilder(
      builder: (context, box) {
        final w = (box.maxWidth - 10) / 2;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final e in o.sweeteners.entries)
              PressScale(
                onTap: () {
                  StudioHaptics.select();
                  if (!s.toggleSweetener(e.key)) _snack('Máximo ${o.maxSweeteners} endulzantes');
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutCubic,
                  width: w,
                  padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
                  decoration: StudioUi.choice(dark, selected: s.sweeteners.contains(e.key)),
                  child: Row(
                    children: [
                      AnimatedRotation(
                        turns: s.sweeteners.contains(e.key) ? 0.02 : 0,
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOutBack,
                        child: SweetenerPacket(name: e.key, width: 26, angle: -0.12),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.key, maxLines: 2, overflow: TextOverflow.ellipsis, style: StudioUi.name(dark).copyWith(fontSize: 12.5, height: 1.15)),
                            const SizedBox(height: 2),
                            Text(e.value == 0 ? 'Incluido' : formatExtra(e.value), style: StudioUi.price),
                          ],
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: s.sweeteners.contains(e.key)
                            ? const Icon(Icons.check_circle_rounded, key: ValueKey('on'), size: 20, color: StudioColors.primary)
                            : const SizedBox(key: ValueKey('off'), width: 0),
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

  // ───────────── Jarabes ─────────────

  Widget _syrupGrid(BuildContext context, DrinkStudioProvider s) {
    final o = s.options!;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final e in o.syrups.entries)
          OptionCard(
            label: e.key,
            caption: formatExtra(e.value),
            selected: s.syrups.contains(e.key),
            onTap: () {
              StudioHaptics.select();
              if (!s.toggleSyrup(e.key)) _snack('Máximo ${o.maxSyrups} jarabes');
            },
          ),
      ],
    );
  }
}
