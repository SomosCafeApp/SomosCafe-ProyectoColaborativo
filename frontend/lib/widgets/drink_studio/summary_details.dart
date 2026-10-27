import 'package:flutter/material.dart';

import '../../core/utils/money_format.dart';
import '../../providers/drink_studio_provider.dart';
import 'studio_colors.dart';

/// Detalle de la bebida preparada: solo lo que de verdad se eligió.
class SummaryDetails extends StatelessWidget {
  const SummaryDetails({super.key, required this.studio});
  final DrinkStudioProvider studio;

  List<(IconData, String, String)> get _rows {
    final s = studio;
    String list(Iterable<String> v) => v.isEmpty ? 'Ninguno' : (v.toList()..sort()).join(', ');
    return [
      (Icons.straighten_rounded, 'Tamaño', s.ounces != null ? '${s.size} · ${s.ounces} oz' : s.size),
      (Icons.thermostat_rounded, 'Tipo', s.type),
      (Icons.water_drop_rounded, 'Leche', '${s.milk} · ${s.milkLevel < 0.02 ? 'sin leche' : s.milkLevel < 0.3 ? 'poca' : s.milkLevel < 0.65 ? 'media' : 'mucha'}'),
      if ((s.profile?.isCoffee ?? false) && s.shots > 0) (Icons.coffee_rounded, 'Shots extra', '+${s.shots}'),
      if (s.options!.hasSyrups) (Icons.opacity_rounded, 'Jarabes', list(s.syrups)),
      if (s.options!.hasSweeteners) (Icons.grain_rounded, 'Endulzantes', list(s.sweeteners)),
      if (s.options!.toppings.isNotEmpty) (Icons.auto_awesome_rounded, 'Toppings', list(s.toppings)),
      if (s.canLatteArt) (Icons.brush_rounded, 'Decoración', s.latteArt.isEmpty ? 'Sin latte art' : s.latteArt),
      if (s.availablePairings.isNotEmpty) (Icons.cake_rounded, 'Acompañamiento', list(s.pairings.values.map((p) => p.name))),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: StudioColors.soft(dark), borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          for (final r in _rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(r.$1, size: 18, color: StudioColors.primary),
                  const SizedBox(width: 10),
                  Text(r.$2, style: TextStyle(fontSize: 13, color: StudioColors.muted(dark))),
                  const SizedBox(width: 12),
                  Expanded(child: Text(r.$3, textAlign: TextAlign.end, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: StudioColors.text(dark)))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Desglose de precio con cantidad y total actualizado.
class SummaryPrice extends StatelessWidget {
  const SummaryPrice({super.key, required this.studio});
  final DrinkStudioProvider studio;

  @override
  Widget build(BuildContext context) {
    final s = studio;
    final dark = Theme.of(context).brightness == Brightness.dark;
    Widget line(String a, String b, {bool bold = false}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(children: [
            Expanded(child: Text(a, style: TextStyle(fontSize: bold ? 16 : 13, fontWeight: bold ? FontWeight.w900 : FontWeight.w500, color: StudioColors.text(dark)))),
            Text(b, style: TextStyle(fontSize: bold ? 20 : 13, fontWeight: bold ? FontWeight.w900 : FontWeight.w700, color: bold ? StudioColors.primary : StudioColors.text(dark))),
          ]),
        );
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: StudioColors.panel(dark), borderRadius: BorderRadius.circular(20), border: Border.all(color: StudioColors.primary.withValues(alpha: 0.35))),
      child: Column(
        children: [
          Row(children: [
            Expanded(child: Text('Cantidad', style: TextStyle(fontWeight: FontWeight.w700, color: StudioColors.text(dark)))),
            IconButton(onPressed: s.quantity > 1 ? () => s.changeQuantity(-1) : null, icon: const Icon(Icons.remove_circle_outline_rounded)),
            Text('${s.quantity}', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: StudioColors.text(dark))),
            IconButton(onPressed: () => s.changeQuantity(1), icon: const Icon(Icons.add_circle_outline_rounded)),
          ]),
          line('Bebida base', formatCop(s.product.effectivePrice)),
          line('Personalización', formatExtra(s.extraPerUnit)),
          if (s.quantity > 1) line('Subtotal × ${s.quantity}', formatCop(s.drinkTotal)),
          if (s.pairings.isNotEmpty) line('Acompañamientos', formatCop(s.pairingsTotal)),
          const Divider(height: 18),
          line('Total', formatCop(s.total), bold: true),
        ],
      ),
    );
  }
}
