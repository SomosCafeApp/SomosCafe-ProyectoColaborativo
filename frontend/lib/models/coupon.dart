import 'promotion.dart';

/// Formato de pesos con separador de miles: 12000 → "12.000".
String couponMoney(double value) =>
    value.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');

/// Cupón del catálogo de recompensas (lo crea el admin).
/// Lo usan dos vistas:
///  - cliente  (GET /coupons): trae `remaining`, `soldOut`, `alreadyRedeemed`
///  - admin    (GET /coupons/admin): trae `redeemLimit`, `redeemedCount`, `isActive`
class Coupon {
  final String id;

  /// REWARD (se canjea con puntos) · WELCOME (regalo al registrarse) ·
  /// BIRTHDAY (regalo de cumpleaños). Los de regalo no cuestan puntos ni
  /// salen en el catálogo: se entregan solos.
  final String kind;
  final String name;
  final String description;
  final PromotionDiscountType discountType;
  final double discountValue;

  /// Tope del descuento en pesos (solo en porcentaje). null = sin tope.
  final double? maximumDiscount;

  /// Compra mínima en productos para poder usarlo (0 = sin mínimo).
  final double minimumPurchase;
  final int pointsCost;

  /// Días para usarlo después de canjearlo. null = no vence.
  final int? validDays;

  // ---- Vista cliente ----
  final int? remaining;
  final bool soldOut;
  final bool alreadyRedeemed;

  // ---- Vista admin ----
  final int? redeemLimit;
  final int redeemedCount;
  final bool isActive;

  const Coupon({
    required this.id,
    this.kind = 'REWARD',
    required this.name,
    required this.description,
    required this.discountType,
    required this.discountValue,
    this.maximumDiscount,
    this.minimumPurchase = 0,
    required this.pointsCost,
    this.validDays,
    this.remaining,
    this.soldOut = false,
    this.alreadyRedeemed = false,
    this.redeemLimit,
    this.redeemedCount = 0,
    this.isActive = true,
  });

  /// "30% OFF" o "$5.000 OFF".
  String get label => discountLabel(discountType, discountValue);

  bool get isGift => kind == 'WELCOME' || kind == 'BIRTHDAY';

  String get kindLabel {
    switch (kind) {
      case 'WELCOME':
        return 'Regalo de bienvenida';
      case 'BIRTHDAY':
        return 'Regalo de cumpleaños';
      default:
        return 'Canjeable con puntos';
    }
  }

  /// Se puede canjear: no agotado y no canjeado ya en este ciclo.
  bool get isRedeemable => !soldOut && !alreadyRedeemed;

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      kind: json['kind'] as String? ?? 'REWARD',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      discountType: parseDiscountType(json['discountType'] as String?),
      discountValue: (json['discountValue'] as num?)?.toDouble() ?? 0,
      maximumDiscount: (json['maximumDiscount'] as num?)?.toDouble(),
      minimumPurchase: (json['minimumPurchase'] as num?)?.toDouble() ?? 0,
      pointsCost: (json['pointsCost'] as num?)?.toInt() ?? 0,
      validDays: (json['validDays'] as num?)?.toInt(),
      remaining: (json['remaining'] as num?)?.toInt(),
      soldOut: json['soldOut'] as bool? ?? false,
      alreadyRedeemed: json['alreadyRedeemed'] as bool? ?? false,
      redeemLimit: (json['redeemLimit'] as num?)?.toInt(),
      redeemedCount: (json['redeemedCount'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}

enum UserCouponStatus { available, used, expired }

UserCouponStatus parseUserCouponStatus(String? raw) {
  switch (raw) {
    case 'USED':
      return UserCouponStatus.used;
    case 'EXPIRED':
      return UserCouponStatus.expired;
    default:
      return UserCouponStatus.available;
  }
}

extension UserCouponStatusX on UserCouponStatus {
  String get label {
    switch (this) {
      case UserCouponStatus.available:
        return 'Disponible';
      case UserCouponStatus.used:
        return 'Usado';
      case UserCouponStatus.expired:
        return 'Vencido';
    }
  }
}

/// Cupón que el cliente ya canjeó (GET /coupons/mine).
/// Guarda las condiciones del momento del canje.
class UserCoupon {
  final String id;
  final String code;

  /// REDEEM (canjeado con puntos) · WELCOME · BIRTHDAY (regalos).
  final String source;
  final String name;
  final String description;
  final PromotionDiscountType discountType;
  final double discountValue;
  final double? maximumDiscount;
  final double minimumPurchase;
  final int pointsSpent;
  final UserCouponStatus status;
  final DateTime? expiresAt;
  final DateTime? usedAt;

  const UserCoupon({
    required this.id,
    required this.code,
    this.source = 'REDEEM',
    required this.name,
    required this.description,
    required this.discountType,
    required this.discountValue,
    this.maximumDiscount,
    this.minimumPurchase = 0,
    required this.pointsSpent,
    required this.status,
    this.expiresAt,
    this.usedAt,
  });

  String get label => discountLabel(discountType, discountValue);

  /// Etiqueta de los cupones que llegaron de regalo (null si se canjeó).
  String? get giftLabel {
    switch (source) {
      case 'WELCOME':
        return 'Regalo de bienvenida 🎁';
      case 'BIRTHDAY':
        return 'Regalo de cumpleaños 🎂';
      default:
        return null;
    }
  }

  /// Disponible Y todavía no vencido (se revisa con el reloj del
  /// teléfono por si venció después de cargar la lista; el servidor
  /// vuelve a validarlo al crear el pedido).
  bool get isUsable =>
      status == UserCouponStatus.available && (expiresAt == null || expiresAt!.isAfter(DateTime.now()));

  /// ¿La compra (productos ya con promociones) alcanza el mínimo?
  bool isApplicableTo(double merchandiseTotal) => merchandiseTotal >= minimumPurchase;

  /// Descuento informativo sobre [merchandiseTotal]. El servidor
  /// calcula el valor real al crear el pedido (mismas reglas).
  double discountFor(double merchandiseTotal) {
    var discount =
        discountType == PromotionDiscountType.percentage ? merchandiseTotal * (discountValue / 100) : discountValue;
    if (maximumDiscount != null && discount > maximumDiscount!) discount = maximumDiscount!;
    if (discount > merchandiseTotal) discount = merchandiseTotal;
    return discount < 0 ? 0 : discount.roundToDouble();
  }

  factory UserCoupon.fromJson(Map<String, dynamic> json) {
    DateTime? date(dynamic raw) => raw is String ? DateTime.tryParse(raw)?.toLocal() : null;

    return UserCoupon(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      code: json['code'] as String? ?? '',
      source: json['source'] as String? ?? 'REDEEM',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      discountType: parseDiscountType(json['discountType'] as String?),
      discountValue: (json['discountValue'] as num?)?.toDouble() ?? 0,
      maximumDiscount: (json['maximumDiscount'] as num?)?.toDouble(),
      minimumPurchase: (json['minimumPurchase'] as num?)?.toDouble() ?? 0,
      pointsSpent: (json['pointsSpent'] as num?)?.toInt() ?? 0,
      status: parseUserCouponStatus(json['status'] as String?),
      expiresAt: date(json['expiresAt']),
      usedAt: date(json['usedAt']),
    );
  }
}
