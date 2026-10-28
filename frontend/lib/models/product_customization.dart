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

  /// Ajuste por tamaño sobre el precio base (puede ser negativo):
  /// Pequeño = base - 3.000 · Mediano = base · Grande = base + 5.000.
  static const Map<String, double> sizePrices = {
    'Pequeño': -3000,
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
    'Cacao en polvo': 1000,
    'Virutas de chocolate': 2000,
    'Malvaviscos': 1800,
  };

  /// Cada porción extra del mismo topping suma esto (la primera se
  /// cobra al precio de [toppingPrices]). Igual que el backend.
  static const double toppingExtraPortionPrice = 300;
  static const int maxToppingQuantity = 5;

  /// Precio de un topping según sus porciones (0 = no se cobra).
  static double toppingLinePrice(double unitPrice, int quantity) =>
      quantity <= 0 ? 0 : unitPrice + (quantity - 1) * toppingExtraPortionPrice;

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

  /// Porciones por topping ({'Canela': 2}). Un topping de [toppings]
  /// sin entrada aquí cuenta como 1 porción.
  final Map<String, int> toppingQuantities;
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
    Map<String, int>? toppingQuantities,
    Set<String>? syrups,
    Set<String>? sweeteners,
    this.latteArt = '',
  })  : toppings = toppings ?? <String>{},
        toppingQuantities = toppingQuantities ?? <String, int>{},
        syrups = syrups ?? <String>{},
        sweeteners = sweeteners ?? <String>{};

  bool get hasLatteArt => latteArt.isNotEmpty;

  /// Porciones del topping [name] (0 si no está elegido).
  int quantityOf(String name) =>
      toppings.contains(name) ? (toppingQuantities[name] ?? 1) : 0;

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
      extra += toppingLinePrice(toppingPrices[topping] ?? 0, quantityOf(topping));
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
    Map<String, int>? toppingQuantities,
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
        toppingQuantities: toppingQuantities ?? Map<String, int>.from(this.toppingQuantities),
        syrups: syrups ?? Set<String>.from(this.syrups),
        sweeteners: sweeteners ?? Set<String>.from(this.sweeteners),
        latteArt: latteArt ?? this.latteArt,
      );

  /// Clave estable para comparar personalizaciones (listas ordenadas),
  /// igual que `customizationKey` del backend (los campos nuevos solo
  /// se agregan cuando traen algo).
  String get key {
    final sorted = (toppings.toList()..sort()).map((t) {
      final q = quantityOf(t);
      return q > 1 ? '${t}x$q' : t;
    });
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
      ...(toppings.toList()..sort()).map((t) {
        final q = quantityOf(t);
        return q > 1 ? '$t x$q' : t;
      }),
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
        'toppings': {
          for (final t in (toppings.toList()..sort())) t: quantityOf(t),
        },
        'syrups': (syrups.toList()..sort()),
        'sweeteners': (sweeteners.toList()..sort()),
        'latteArt': latteArt,
      };

  factory ProductCustomization.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ProductCustomization();
    Set<String> names(String field) =>
        (json[field] as List?)?.map((e) => e.toString()).toSet() ?? <String>{};

    // El backend devuelve la lista de nombres + toppingQuantities; al
    // enviar usamos el mapa {nombre: porciones}. Se aceptan ambos.
    final rawToppings = json['toppings'];
    final rawQty = json['toppingQuantities'];
    final quantities = <String, int>{};
    if (rawToppings is Map) {
      rawToppings.forEach((k, v) {
        final q = (v as num?)?.toInt() ?? 0;
        if (q > 0) quantities[k.toString()] = q;
      });
    } else if (rawToppings is List) {
      for (final name in rawToppings) {
        final q = rawQty is Map ? (rawQty[name] as num?)?.toInt() ?? 1 : 1;
        if (q > 0) quantities[name.toString()] = q;
      }
    }

    return ProductCustomization(
      size: json['size'] as String? ?? defaultSize,
      type: json['type'] as String? ?? defaultType,
      milk: json['milk'] as String? ?? defaultMilk,
      extraShots: (json['extraShots'] as num?)?.toInt() ?? 0,
      toppings: quantities.keys.toSet(),
      toppingQuantities: quantities,
      syrups: names('syrups'),
      sweeteners: names('sweeteners'),
      latteArt: json['latteArt'] is String ? json['latteArt'] as String : '',
    );
  }
}
