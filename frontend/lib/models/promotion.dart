/// Producto asignado a una promoción (versión liviana: solo lo que
/// necesita el panel admin para listarlo y volver a seleccionarlo).
class PromotionProduct {
  final String id;
  final String name;
  final double price;

  const PromotionProduct({required this.id, required this.name, this.price = 0});

  factory PromotionProduct.fromJson(Map<String, dynamic> json) => PromotionProduct(
        id: (json['_id'] ?? json['id'] ?? '').toString(),
        name: json['name'] as String? ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0,
      );
}

enum PromotionDiscountType { percentage, fixed }

extension PromotionDiscountTypeX on PromotionDiscountType {
  String get apiValue => this == PromotionDiscountType.percentage ? 'percentage' : 'fixed';

  String get label => this == PromotionDiscountType.percentage ? 'Porcentaje (%)' : 'Valor fijo (\$)';
}

PromotionDiscountType parseDiscountType(String? raw) =>
    raw == 'fixed' ? PromotionDiscountType.fixed : PromotionDiscountType.percentage;

/// Estado calculado de una promoción para mostrar en el admin.
enum PromotionStatus { active, disabled, scheduled, expired }

extension PromotionStatusX on PromotionStatus {
  String get label {
    switch (this) {
      case PromotionStatus.active:
        return 'Vigente';
      case PromotionStatus.disabled:
        return 'Deshabilitada';
      case PromotionStatus.scheduled:
        return 'Programada';
      case PromotionStatus.expired:
        return 'Vencida';
    }
  }
}

String _formatMoney(double value) => value
    .toStringAsFixed(0)
    .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');

/// Etiqueta corta de un descuento: "30% OFF" o "$2.000 OFF".
String discountLabel(PromotionDiscountType type, double value) {
  if (type == PromotionDiscountType.percentage) {
    return '${value.toStringAsFixed(value % 1 == 0 ? 0 : 1)}% OFF';
  }
  return '\$${_formatMoney(value)} OFF';
}

/// Promoción tal como la ve el administrador (GET /promotions).
class Promotion {
  final String id;
  final String code;
  final String name;
  final String description;
  final PromotionDiscountType discountType;
  final double discountValue;

  /// Tope del descuento por unidad (null = sin tope).
  final double? maximumDiscount;
  final List<PromotionProduct> products;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final bool isPromoOfTheDay;

  const Promotion({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.maximumDiscount,
    required this.products,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.isPromoOfTheDay,
  });

  String get label => discountLabel(discountType, discountValue);

  PromotionStatus get status {
    if (!isActive) return PromotionStatus.disabled;
    final now = DateTime.now();
    if (now.isBefore(startDate)) return PromotionStatus.scheduled;
    if (now.isAfter(endDate)) return PromotionStatus.expired;
    return PromotionStatus.active;
  }

  factory Promotion.fromJson(Map<String, dynamic> json) {
    final rawProducts = json['productIds'] as List? ?? [];

    return Promotion(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      discountType: parseDiscountType(json['discountType'] as String?),
      discountValue: (json['discountValue'] as num?)?.toDouble() ?? 0,
      maximumDiscount: (json['maximumDiscount'] as num?)?.toDouble(),
      // productIds viene poblado ({_id, name, price}); si el producto
      // fue borrado puede venir null o como simple id, lo descartamos.
      products: rawProducts
          .whereType<Map<String, dynamic>>()
          .map(PromotionProduct.fromJson)
          .toList(),
      startDate: DateTime.tryParse(json['startDate'] as String? ?? '')?.toLocal() ?? DateTime.now(),
      endDate: DateTime.tryParse(json['endDate'] as String? ?? '')?.toLocal() ?? DateTime.now(),
      isActive: json['isActive'] as bool? ?? true,
      isPromoOfTheDay: json['isPromoOfTheDay'] as bool? ?? false,
    );
  }
}

/// Producto dentro de la promo del día (GET /promotions/promo-of-the-day).
class PromoDayProduct {
  final String id;
  final String name;
  final String image;
  final double price;
  final double discountedPrice;

  const PromoDayProduct({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.discountedPrice,
  });

  factory PromoDayProduct.fromJson(Map<String, dynamic> json) {
    final price = (json['price'] as num?)?.toDouble() ?? 0;
    return PromoDayProduct(
      id: (json['_id'] ?? '').toString(),
      name: json['name'] as String? ?? '',
      image: json['image'] as String? ?? '',
      price: price,
      discountedPrice: (json['discountedPrice'] as num?)?.toDouble() ?? price,
    );
  }
}

/// Promo del día tal como la ve el cliente en el home.
class PromoOfTheDay {
  final String id;
  final String name;
  final String description;
  final PromotionDiscountType discountType;
  final double discountValue;
  final DateTime? endDate;
  final List<PromoDayProduct> products;

  const PromoOfTheDay({
    required this.id,
    required this.name,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.endDate,
    required this.products,
  });

  String get label => discountLabel(discountType, discountValue);

  /// Texto grande del banner: "¡30% de descuento!" / "¡$2.000 de descuento!".
  String get headline => discountType == PromotionDiscountType.percentage
      ? '¡${discountValue.toStringAsFixed(discountValue % 1 == 0 ? 0 : 1)}% de descuento!'
      : '¡\$${_formatMoney(discountValue)} de descuento!';

  /// Valor corto para el círculo amarillo: "30%" / "$2.000".
  String get badgeValue => discountType == PromotionDiscountType.percentage
      ? '${discountValue.toStringAsFixed(discountValue % 1 == 0 ? 0 : 1)}%'
      : '\$${_formatMoney(discountValue)}';

  factory PromoOfTheDay.fromJson(Map<String, dynamic> json) {
    return PromoOfTheDay(
      id: (json['_id'] ?? '').toString(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      discountType: parseDiscountType(json['discountType'] as String?),
      discountValue: (json['discountValue'] as num?)?.toDouble() ?? 0,
      endDate: DateTime.tryParse(json['endDate'] as String? ?? '')?.toLocal(),
      products: (json['products'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(PromoDayProduct.fromJson)
          .toList(),
    );
  }
}
