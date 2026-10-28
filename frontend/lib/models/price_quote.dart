/// Una línea del desglose de precio (por unidad), por ejemplo
/// "Canela × 3" → $1.600 con detalle "2 extra × $300".
class PriceLine {
  final String label;
  final String? detail;
  final double amount;
  const PriceLine(this.label, this.amount, {this.detail});
}

/// Precio de UNA unidad con todo el detalle. Replica exactamente el
/// cálculo del backend (`utils/pricing.js`), así que lo que se ve en el
/// detalle, el estudio y el carrito es lo que luego se cobra.
///
///   basePrice          precio del producto (tamaño Mediano)
///   sizeAdjustment     Pequeño -3.000 · Mediano 0 · Grande +5.000
///   lines              adicionales con precio (leche, shots, toppings…)
///   originalUnitPrice  basePrice + sizeAdjustment + extras  (sin promo)
///   discountPerUnit    promoción sobre el precio base, sin pasar nunca
///                      del precio de la unidad
///   unitPrice          originalUnitPrice - discountPerUnit
class PriceQuote {
  final double basePrice;
  final String size;
  final double sizeAdjustment;
  final List<PriceLine> lines;
  final double discountPerUnit;
  final String? promotionName;

  const PriceQuote({
    required this.basePrice,
    required this.size,
    required this.sizeAdjustment,
    required this.lines,
    this.discountPerUnit = 0,
    this.promotionName,
  });

  /// Suma de los adicionales (sin el ajuste de tamaño).
  double get extrasTotal => lines.fold(0.0, (a, l) => a + l.amount);

  /// Lo que suma la personalización completa: tamaño + adicionales.
  double get customizationPrice => sizeAdjustment + extrasTotal;

  double get originalUnitPrice => basePrice + customizationPrice;
  double get unitPrice => originalUnitPrice - discountPerUnit;
  bool get hasDiscount => discountPerUnit > 0;

  double subtotal(int quantity) => originalUnitPrice * quantity;
  double discount(int quantity) => discountPerUnit * quantity;
  double total(int quantity) => unitPrice * quantity;
}
