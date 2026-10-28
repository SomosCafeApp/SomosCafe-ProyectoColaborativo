import 'package:flutter/material.dart';

import '../common/price_breakdown_card.dart';
import '../../providers/drink_studio_provider.dart';
import 'latte_art_shapes.dart';
import 'studio_colors.dart';
import 'studio_ui.dart';
import 'sweetener_packet.dart';
import 'topping_icon.dart';

/// Lo que lleva la bebida, mostrado de forma visual: datos básicos en
/// píldoras, el arte latte, los toppings con sus porciones y los
/// endulzantes como sobres. Solo aparece lo que de verdad se eligió.
class SummaryDetails extends StatelessWidget {
  const SummaryDetails({super.key, required this.studio});
  final DrinkStudioProvider studio;

  @override
  Widget build(BuildContext context) {
    final s = studio;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final milkAmount = s.milkLevel < 0.02 ? 'sin leche' : s.milkLevel < 0.3 ? 'poca' : s.milkLevel < 0.65 ? 'media' : 'mucha';
    final toppings = s.toppings.toList()..sort();
    final sweeteners = s.sweeteners.toList()..sort();
    final syrups = s.syrups.toList()..sort();

    Widget pill(IconData icon, String text) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: StudioColors.soft(dark), borderRadius: BorderRadius.circular(30)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: StudioColors.primary),
              const SizedBox(width: 6),
              Text(text, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: StudioColors.text(dark))),
            ],
          ),
        );

    Widget card(String label, Widget child) => Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          decoration: BoxDecoration(color: StudioColors.soft(dark), borderRadius: BorderRadius.circular(22)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [SectionLabel(label), child]),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            pill(Icons.straighten_rounded, s.ounces != null ? '${s.size} · ${s.ounces} oz' : s.size),
            pill(Icons.thermostat_rounded, s.type),
            pill(Icons.water_drop_rounded, '${s.milk} · $milkAmount'),
            if ((s.profile?.isCoffee ?? false) && s.shots > 0) pill(Icons.coffee_rounded, '+${s.shots} shot${s.shots > 1 ? 's' : ''}'),
          ],
        ),
        if (s.canLatteArt)
          card(
            'Decoración',
            Row(
              children: [
                if (s.latteArt.isNotEmpty) ...[LatteArtDisc(design: s.latteArt, size: 52), const SizedBox(width: 12)],
                Expanded(child: Text(s.latteArt.isEmpty ? 'Sin arte latte' : 'Arte latte · ${s.latteArt}', style: StudioUi.name(dark))),
              ],
            ),
          ),
        if (toppings.isNotEmpty)
          card(
            'Toppings',
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in toppings)
                  Container(
                    padding: const EdgeInsets.fromLTRB(6, 4, 12, 4),
                    decoration: BoxDecoration(color: StudioColors.panel(dark), borderRadius: BorderRadius.circular(30), border: Border.all(color: StudioColors.primary.withValues(alpha: 0.25))),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ToppingIcon(name: t, size: 28),
                        const SizedBox(width: 6),
                        Text(t, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: StudioColors.text(dark))),
                        if (s.toppingQuantity(t) > 1) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(color: StudioColors.primary, borderRadius: BorderRadius.circular(10)),
                            child: Text('×${s.toppingQuantity(t)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white)),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
        if (sweeteners.isNotEmpty)
          card(
            'Endulzantes · en sobre aparte',
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                for (final w in sweeteners)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SweetenerPacket(name: w, width: 22, angle: -0.1),
                      const SizedBox(width: 4),
                      Text(w, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: StudioColors.text(dark))),
                    ],
                  ),
              ],
            ),
          ),
        if (syrups.isNotEmpty) card('Jarabes', Text(syrups.join(', '), style: StudioUi.name(dark))),
        if (s.availablePairings.isNotEmpty && s.pairings.isNotEmpty) card('Acompañamiento', Text(s.pairings.values.map((p) => p.name).join(', '), style: StudioUi.name(dark))),
      ],
    );
  }
}

/// Desglose de precio de la bebida: base, ajuste por tamaño, cada
/// adicional con su detalle (por ejemplo "2 extra × $300"), descuento,
/// cantidad, acompañamientos y total. Usa el mismo componente (y los
/// mismos valores) que el detalle del producto y el carrito.
class SummaryPrice extends StatelessWidget {
  const SummaryPrice({super.key, required this.studio});
  final DrinkStudioProvider studio;

  @override
  Widget build(BuildContext context) {
    final s = studio;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        PriceBreakdownCard(
          quote: s.quote,
          quantity: s.quantity,
          extraRows: [
            for (final p in s.pairings.values) PriceLine(p.name, p.effectivePrice),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: Text('Cantidad', style: TextStyle(fontWeight: FontWeight.w700, color: StudioColors.text(dark)))),
            QuantityPill(value: s.quantity, onMinus: s.quantity > 1 ? () => s.changeQuantity(-1) : null, onPlus: () => s.changeQuantity(1)),
          ],
        ),
      ],
    );
  }
}
