/// Personalización elegida en ProductDetailPage o en el estudio de
/// bebidas: tamaño, tipo, leche, shots extra, toppings, jarabes,
/// endulzantes y latte art. Viaja en todo el flujo
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

  /// Jarabes y endulzantes: el catálogo real lo manda el backend y se
  /// registra aquí con `DrinkOptions.register()` al abrir el estudio.
  /// Mientras no exista (lista vacía) no suman nada.
  static Map<String, double> syrupPrices = {};
  static Map<String, double> sweetenerPrices = {};

  final String size;
  final String type;
  final String milk;
  final int extraShots;
  final Set<String> toppings;
  final Set<String> syrups;
  final Set<String> sweeteners;

  /// Diseño de latte art: 'Corazón', 'Hoja', 'Cisne' o '' (ninguno).
  final String latteArt;

  ProductCustomization({
    this.size = defaultSize,
    this.type = defaultType,
    this.milk = defaultMilk,
    this.extraShots = 0,
    Set<String>? toppings,
    Set<String>? syrups,
    Set<String>? sweeteners,
    this.latteArt = '',
  })  : toppings = toppings ?? <String>{},
        syrups = syrups ?? <String>{},
        sweeteners = sweeteners ?? <String>{};

  bool get hasLatteArt => latteArt.isNotEmpty;

  /// Sin ninguna opción distinta de las de por defecto.
  bool get isDefault =>
      size == defaultSize &&
      type == defaultType &&
      milk == defaultMilk &&
      extraShots == 0 &&
      toppings.isEmpty &&
      syrups.isEmpty &&
      sweeteners.isEmpty &&
      latteArt.isEmpty;

  /// Extra por unidad que suman las opciones (sin el precio base).
  double get extraPrice {
    double extra = 0;
    extra += sizePrices[size] ?? 0;
    extra += milkPrices[milk] ?? 0;
    extra += extraShots * extraShotPrice;
    for (final topping in toppings) {
      extra += toppingPrices[topping] ?? 0;
    }
    for (final syrup in syrups) {
      extra += syrupPrices[syrup] ?? 0;
    }
    for (final sweetener in sweeteners) {
      extra += sweetenerPrices[sweetener] ?? 0;
    }
    return extra;
  }

  double calculateTotalPrice(double basePrice, int quantity) =>
      (basePrice + extraPrice) * quantity;

  ProductCustomization copyWith({
    String? size,
    String? type,
    String? milk,
    int? extraShots,
    Set<String>? toppings,
    Set<String>? syrups,
    Set<String>? sweeteners,
    String? latteArt,
  }) =>
      ProductCustomization(
        size: size ?? this.size,
        type: type ?? this.type,
        milk: milk ?? this.milk,
        extraShots: extraShots ?? this.extraShots,
        toppings: toppings ?? Set<String>.from(this.toppings),
        syrups: syrups ?? Set<String>.from(this.syrups),
        sweeteners: sweeteners ?? Set<String>.from(this.sweeteners),
        latteArt: latteArt ?? this.latteArt,
      );

  /// Clave estable para comparar personalizaciones (listas ordenadas),
  /// igual que `customizationKey` del backend (los campos nuevos solo
  /// se agregan cuando traen algo).
  String get key {
    final sorted = toppings.toList()..sort();
    final parts = <Object>[size, type, milk, extraShots, sorted.join(',')];
    if (syrups.isNotEmpty) parts.add('s:${(syrups.toList()..sort()).join(',')}');
    if (sweeteners.isNotEmpty) parts.add('w:${(sweeteners.toList()..sort()).join(',')}');
    if (latteArt.isNotEmpty) parts.add('a:$latteArt');
    return parts.join('|');
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

    final extras = <String>[
      ...(syrups.toList()..sort()),
      ...(sweeteners.toList()..sort()),
      ...(toppings.toList()..sort()),
      if (latteArt.isNotEmpty) 'Latte art: $latteArt',
    ];

    return [
      if (options.isNotEmpty) options.join(' · '),
      if (extras.isNotEmpty) extras.join(' · '),
    ];
  }

  Map<String, dynamic> toJson() => {
        'size': size,
        'type': type,
        'milk': milk,
        'extraShots': extraShots,
        'toppings': (toppings.toList()..sort()),
        'syrups': (syrups.toList()..sort()),
        'sweeteners': (sweeteners.toList()..sort()),
        'latteArt': latteArt,
      };

  factory ProductCustomization.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ProductCustomization();
    Set<String> names(String field) =>
        (json[field] as List?)?.map((e) => e.toString()).toSet() ?? <String>{};

    return ProductCustomization(
      size: json['size'] as String? ?? defaultSize,
      type: json['type'] as String? ?? defaultType,
      milk: json['milk'] as String? ?? defaultMilk,
      extraShots: (json['extraShots'] as num?)?.toInt() ?? 0,
      toppings: names('toppings'),
      syrups: names('syrups'),
      sweeteners: names('sweeteners'),
      latteArt: json['latteArt'] is String ? json['latteArt'] as String : '',
    );
  }
}
