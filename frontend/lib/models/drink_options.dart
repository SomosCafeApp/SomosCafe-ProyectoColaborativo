import 'product_customization.dart';

/// Regla de compatibilidad de un topping con la bebida (la define el
/// backend en `TOPPING_RULES`; aquí solo se aplica para no mostrar
/// ingredientes que el pedido luego rechazaría).
class ToppingRule {
  final List<String> types;
  final List<String> keywords;
  final List<String> exclude;

  const ToppingRule({this.types = const [], this.keywords = const [], this.exclude = const []});

  factory ToppingRule.fromJson(dynamic raw) {
    if (raw is! Map) return const ToppingRule();
    List<String> list(String k) => (raw[k] as List?)?.map((e) => e.toString().toLowerCase()).toList() ?? const [];
    return ToppingRule(
      types: (raw['types'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      keywords: list('keywords'),
      exclude: list('exclude'),
    );
  }

  /// [text] es nombre + categoría de la bebida en minúsculas.
  bool allows({required String text, required String type}) {
    if (types.isNotEmpty && !types.contains(type)) return false;
    if (exclude.any(text.contains)) return false;
    if (keywords.isNotEmpty && !keywords.any(text.contains)) return false;
    return true;
  }
}

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
  final double toppingExtraPortionPrice;
  final int maxToppingQuantity;

  /// Piso del tamaño Pequeño (ver backend `MIN_PRICE_AFTER_SIZE`).
  final double minPriceAfterSize;

  /// Compatibilidad por topping (sin regla = va con cualquier bebida).
  final Map<String, ToppingRule> toppingCompat;
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
    required this.toppingExtraPortionPrice,
    required this.maxToppingQuantity,
    this.minPriceAfterSize = 1000,
    this.toppingCompat = const {},
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
    final toppingRules = (json['toppingRules'] as Map?) ?? const {};
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
      toppingExtraPortionPrice: (toppingRules['extraPortionPrice'] as num?)?.toDouble() ??
          ProductCustomization.toppingExtraPortionPrice,
      maxToppingQuantity:
          (toppingRules['maxQuantity'] as num?)?.toInt() ?? ProductCustomization.maxToppingQuantity,
      minPriceAfterSize: ((json['sizeRules'] as Map?)?['minPriceAfterSize'] as num?)?.toDouble() ?? 1000,
      toppingCompat: {
        for (final e in ((toppingRules['compatibility'] as Map?) ?? const {}).entries) e.key.toString(): ToppingRule.fromJson(e.value),
      },
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

  /// Toppings que van con una bebida de nombre y categoría [drinkText]
  /// servida en [type] ("Caliente" / "Frío"), con su precio.
  Map<String, double> toppingsFor(String drinkText, String type) {
    final text = drinkText.toLowerCase();
    return {
      for (final e in toppings.entries)
        if (toppingCompat[e.key] == null || toppingCompat[e.key]!.allows(text: text, type: type)) e.key: e.value,
    };
  }

  /// Deja TODAS las tablas de precios del servidor disponibles para
  /// `ProductCustomization` (detalle, carrito optimista, resúmenes), de
  /// modo que la app nunca calcule con valores distintos a los que cobra
  /// el backend.
  void register() {
    ProductCustomization.sizePrices = Map<String, double>.from(sizes);
    ProductCustomization.minPriceAfterSize = minPriceAfterSize;
    ProductCustomization.milkPrices = Map<String, double>.from(milks);
    ProductCustomization.extraShotPrice = extraShotPrice;
    ProductCustomization.toppingPrices = Map<String, double>.from(toppings);
    ProductCustomization.toppingExtraPortionPrice = toppingExtraPortionPrice;
    ProductCustomization.maxToppingQuantity = maxToppingQuantity;
    ProductCustomization.syrupPrices = Map<String, double>.from(syrups);
    ProductCustomization.sweetenerPrices = Map<String, double>.from(sweeteners);
  }

  /// Extra por unidad de [c] con los precios reales del servidor.
  /// [basePrice] (precio de lista) activa las reglas de tamaño del
  /// producto; sin él se usa el ajuste crudo de la tabla.
  double extraPriceOf(ProductCustomization c, {double? basePrice}) {
    double size = sizes[c.size] ?? 0;
    if (size < 0 && basePrice != null) {
      final room = basePrice - minPriceAfterSize;
      size = -(room <= 0 ? 0.0 : (-size < room ? -size : room));
    }
    double extra = size + (milks[c.milk] ?? 0) + c.extraShots * extraShotPrice;
    for (final t in c.toppings) {
      final qty = c.quantityOf(t);
      if (qty > 0) extra += (toppings[t] ?? 0) + (qty - 1) * toppingExtraPortionPrice;
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
