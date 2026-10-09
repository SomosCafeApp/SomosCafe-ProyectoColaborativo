/// Personalización elegida en ProductDetailPage: tamaño, tipo, leche,
/// shots extra y toppings. Viaja en todo el flujo
/// (ProductDetail → Cart → Order → OrdersPage) y es lo que el backend
/// valida y recalcula (utils/customization.js: mismos nombres y precios).
///
/// Los precios de aquí solo sirven para MOSTRAR el total en pantalla
/// antes de agregar; el precio real siempre lo calcula el servidor.
class ProductCustomization {
  static const String defaultSize = 'Mediano';
  static const String defaultType = 'Caliente';
  static const String defaultMilk = 'Entera';

  static const Map<String, double> sizePrices = {
    'Pequeño': 3000,
    'Mediano': 0,
    'Grande': 5000,
  };

  static const Map<String, double> milkPrices = {
    'Entera': 0,
    'Almendra': 1000,
    'Avena': 1000,
    'Soya': 2000,
  };

  static const double extraShotPrice = 3000;

  static const Map<String, double> toppingPrices = {
    'Crema batida': 2000,
    'Canela': 1000,
    'Chispas': 2500,
    'Caramelo': 1500,
  };

  final String size;
  final String type;
  final String milk;
  final int extraShots;
  final Set<String> toppings;

  ProductCustomization({
    this.size = defaultSize,
    this.type = defaultType,
    this.milk = defaultMilk,
    this.extraShots = 0,
    Set<String>? toppings,
  }) : toppings = toppings ?? <String>{};

  /// Sin ninguna opción distinta de las de por defecto.
  bool get isDefault =>
      size == defaultSize &&
      type == defaultType &&
      milk == defaultMilk &&
      extraShots == 0 &&
      toppings.isEmpty;

  /// Extra por unidad que suman las opciones (sin el precio base).
  double get extraPrice {
    double extra = 0;
    extra += sizePrices[size] ?? 0;
    extra += milkPrices[milk] ?? 0;
    extra += extraShots * extraShotPrice;
    for (final topping in toppings) {
      extra += toppingPrices[topping] ?? 0;
    }
    return extra;
  }

  double calculateTotalPrice(double basePrice, int quantity) =>
      (basePrice + extraPrice) * quantity;

  /// Clave estable para comparar personalizaciones (toppings ordenados),
  /// igual que `customizationKey` del backend.
  String get key {
    final sorted = toppings.toList()..sort();
    return [size, type, milk, extraShots, sorted.join(',')].join('|');
  }

  /// Líneas cortas para mostrar en carrito/pedidos. Solo aparece lo que
  /// se aparta de los valores por defecto. Ej.:
  ///   ['Grande · Avena · +2 shots', 'Crema batida · Canela']
  List<String> get summaryLines {
    final options = <String>[
      if (size != defaultSize) size,
      if (type != defaultType) type,
      if (milk != defaultMilk) milk,
      if (extraShots > 0) '+$extraShots ${extraShots == 1 ? 'shot' : 'shots'}',
    ];

    final sortedToppings = toppings.toList()..sort();

    return [
      if (options.isNotEmpty) options.join(' · '),
      if (sortedToppings.isNotEmpty) sortedToppings.join(' · '),
    ];
  }

  Map<String, dynamic> toJson() => {
        'size': size,
        'type': type,
        'milk': milk,
        'extraShots': extraShots,
        'toppings': (toppings.toList()..sort()),
      };

  factory ProductCustomization.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ProductCustomization();
    return ProductCustomization(
      size: json['size'] as String? ?? defaultSize,
      type: json['type'] as String? ?? defaultType,
      milk: json['milk'] as String? ?? defaultMilk,
      extraShots: (json['extraShots'] as num?)?.toInt() ?? 0,
      toppings: (json['toppings'] as List?)?.map((e) => e.toString()).toSet() ?? <String>{},
    );
  }
}
