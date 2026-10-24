import 'product_customization.dart';

/// Opciones reales de personalización que manda el backend
/// (GET /api/customization/options). Es la misma fuente que usa el
/// servidor para validar y cobrar, así que el estudio de bebidas nunca
/// muestra algo que el pedido luego rechace.
class DrinkOptions {
  final Map<String, double> sizes;
  final List<String> types;
  final Map<String, double> milks;
  final double extraShotPrice;
  final int maxExtraShots;
  final Map<String, double> toppings;
  final Map<String, double> syrups;
  final int maxSyrups;
  final Map<String, double> sweeteners;
  final int maxSweeteners;
  final List<String> latteArtKeywords;
  final List<String> coffeeKeywords;
  final List<String> latteArtDesigns;

  /// Onzas de cada tamaño (null si el backend no las manda).
  final Map<String, int> sizeOunces;
  final String defaultSize;
  final String defaultType;
  final String defaultMilk;

  const DrinkOptions({
    required this.sizes,
    required this.types,
    required this.milks,
    required this.extraShotPrice,
    required this.maxExtraShots,
    required this.toppings,
    required this.syrups,
    required this.maxSyrups,
    required this.sweeteners,
    required this.maxSweeteners,
    required this.latteArtKeywords,
    required this.coffeeKeywords,
    required this.latteArtDesigns,
    required this.sizeOunces,
    required this.defaultSize,
    required this.defaultType,
    required this.defaultMilk,
  });

  static Map<String, double> _prices(dynamic raw) {
    if (raw is! Map) return {};
    return {for (final e in raw.entries) e.key.toString(): (e.value as num).toDouble()};
  }

  static List<String> _strings(dynamic raw) =>
      (raw as List?)?.map((e) => e.toString().toLowerCase()).toList() ?? const [];

  /// Onzas del tamaño [size] (null si no hay dato).
  int? ouncesOf(String size) => sizeOunces[size];

  factory DrinkOptions.fromJson(Map<String, dynamic> json) {
    final shot = (json['extraShot'] as Map?) ?? const {};
    final syrups = (json['syrups'] as Map?) ?? const {};
    final sweeteners = (json['sweeteners'] as Map?) ?? const {};
    final art = (json['latteArt'] as Map?) ?? const {};
    final defaults = (json['defaults'] as Map?) ?? const {};

    return DrinkOptions(
      sizes: _prices(json['sizes']),
      types: (json['types'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      milks: _prices(json['milks']),
      extraShotPrice: (shot['price'] as num?)?.toDouble() ?? 0,
      maxExtraShots: (shot['max'] as num?)?.toInt() ?? 0,
      toppings: _prices(json['toppings']),
      syrups: _prices(syrups['prices']),
      maxSyrups: (syrups['max'] as num?)?.toInt() ?? 0,
      sweeteners: _prices(sweeteners['prices']),
      maxSweeteners: (sweeteners['max'] as num?)?.toInt() ?? 0,
      latteArtKeywords: _strings(art['keywords']),
      coffeeKeywords: _strings(json['coffeeKeywords']),
      latteArtDesigns: (art['designs'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      sizeOunces: {
        for (final e in ((json['sizeOunces'] as Map?) ?? const {}).entries) e.key.toString(): (e.value as num).toInt(),
      },
      defaultSize: defaults['size'] as String? ?? ProductCustomization.defaultSize,
      defaultType: defaults['type'] as String? ?? ProductCustomization.defaultType,
      defaultMilk: defaults['milk'] as String? ?? ProductCustomization.defaultMilk,
    );
  }

  /// Sin opciones esenciales no se puede armar la bebida con seguridad.
  bool get isUsable => sizes.isNotEmpty && types.isNotEmpty && milks.isNotEmpty;

  /// Falta el catálogo de jarabes / endulzantes en la base de datos.
  bool get hasSyrups => syrups.isNotEmpty && maxSyrups > 0;
  bool get hasSweeteners => sweeteners.isNotEmpty && maxSweeteners > 0;

  /// Deja los precios de jarabes y endulzantes disponibles para
  /// `ProductCustomization.extraPrice` (carrito optimista, resúmenes).
  void register() {
    ProductCustomization.syrupPrices = Map<String, double>.from(syrups);
    ProductCustomization.sweetenerPrices = Map<String, double>.from(sweeteners);
  }

  /// Extra por unidad de [c] con los precios reales del servidor.
  double extraPriceOf(ProductCustomization c) {
    double extra = (sizes[c.size] ?? 0) + (milks[c.milk] ?? 0) + c.extraShots * extraShotPrice;
    for (final t in c.toppings) {
      extra += toppings[t] ?? 0;
    }
    for (final s in c.syrups) {
      extra += syrups[s] ?? 0;
    }
    for (final s in c.sweeteners) {
      extra += sweeteners[s] ?? 0;
    }
    return extra;
  }
}
