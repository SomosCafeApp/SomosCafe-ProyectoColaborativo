import 'package:flutter/material.dart';

import '../../core/utils/money_format.dart';
import '../../models/price_quote.dart';

/// Desglose transparente del precio: base, ajuste por tamaño,
/// adicionales, descuento y total. Se usa en el detalle del producto, en
/// el estudio y en el carrito, con los mismos datos del servidor.
class PriceBreakdownCard extends StatelessWidget {
  const PriceBreakdownCard({
    super.key,
    required this.quote,
    required this.quantity,
    this.title = 'Resumen de precio',
    this.extraRows = const [],
    this.showTotal = true,
    this.padding = const EdgeInsets.all(16),
  });

  final PriceQuote quote;
  final int quantity;
  final String title;

  /// Filas adicionales sumadas al total (p. ej. acompañamientos).
  final List<PriceLine> extraRows;
  final bool showTotal;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final text = theme.colorScheme.onSurface;
    final muted = text.withValues(alpha: 0.6);
    final primary = theme.colorScheme.primary;

    Widget row(String label, String value, {String? detail, bool bold = false, Color? color, double size = 13.5}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: TextStyle(fontSize: size, fontWeight: bold ? FontWeight.w900 : FontWeight.w600, color: color ?? text)),
                    if (detail != null) Text(detail, style: TextStyle(fontSize: 11.5, color: muted)),
                  ],
                ),
              ),
              Text(value, style: TextStyle(fontSize: size, fontWeight: bold ? FontWeight.w900 : FontWeight.w800, color: color ?? text)),
            ],
          ),
        );

    final sizeLabel = switch (quote.size) { 'Pequeño' => 'Pequeño · 8 oz', 'Mediano' => 'Mediano · 12 oz', 'Grande' => 'Grande · 16 oz', final s => s };
    final extrasTotal = extraRows.fold(0.0, (a, l) => a + l.amount);
    final total = quote.total(quantity) + extrasTotal;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.1, color: muted)),
          const SizedBox(height: 6),
          row('Precio base', formatCop(quote.basePrice), detail: 'Tamaño mediano · 12 oz'),
          if (quote.sizeAdjustment != 0)
            row('Ajuste por tamaño', quote.sizeAdjustment < 0 ? formatCop(quote.sizeAdjustment) : '+${formatCop(quote.sizeAdjustment)}', detail: sizeLabel),
          for (final l in quote.lines) row(l.label, formatExtra(l.amount), detail: l.detail),
          if (quote.hasDiscount) ...[
            const Divider(height: 14),
            row('Descuento${quote.promotionName != null ? ' · ${quote.promotionName}' : ''}', '-${formatCop(quote.discountPerUnit)}', color: const Color(0xFF2E8B57)),
          ],
          if (quantity > 1 || quote.customizationPrice != 0 || quote.hasDiscount) ...[
            const Divider(height: 14),
            row('Precio por unidad', formatCop(quote.unitPrice)),
          ],
          if (quantity > 1) row('Cantidad', '× $quantity'),
          for (final r in extraRows) row(r.label, formatExtra(r.amount), detail: r.detail),
          if (showTotal) ...[
            const Divider(height: 18),
            row('Total', formatCop(total), bold: true, size: 17, color: primary),
          ],
        ],
      ),
    );
  }
}
