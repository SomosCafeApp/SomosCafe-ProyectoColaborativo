import 'payment_method_model.dart';
import 'product_customization.dart';

/// Un producto dentro de una orden ya creada. A diferencia de
/// [Product], esto es una "foto" del producto en el momento de la
/// compra (nombre/precio pueden cambiar después y la orden no se ve
/// afectada), tal como lo guarda el backend en `order.items`.
class OrderItemLine {
  final String productId;
  final String name;
  final String image;

  /// Precio base del producto (sin personalización).
  final double price;

  /// Extra por unidad que sumó la personalización.
  final double customizationPrice;
  final ProductCustomization customization;
  final int quantity;

  /// Importe de la línea ANTES del descuento.
  final double subtotal;

  /// Descuento de promoción aplicado a la línea (total, no por unidad).
  final double discount;
  final String promotionName;

  OrderItemLine({
    required this.productId,
    required this.name,
    required this.image,
    required this.price,
    this.customizationPrice = 0,
    ProductCustomization? customization,
    required this.quantity,
    required this.subtotal,
    this.discount = 0,
    this.promotionName = '',
  }) : customization = customization ?? ProductCustomization();

  double get unitPrice => price + customizationPrice;

  /// Lo que se pagó por la línea (subtotal menos descuento).
  double get netSubtotal => subtotal - discount;

  bool get hasDiscount => discount > 0;

  factory OrderItemLine.fromJson(Map<String, dynamic> json) {
    return OrderItemLine(
      productId: (json['productId'] ?? '').toString(),
      name: json['name'] as String? ?? '',
      image: json['image'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      customizationPrice: (json['customizationPrice'] as num?)?.toDouble() ?? 0,
      customization: ProductCustomization.fromJson(json['customization'] as Map<String, dynamic>?),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      promotionName: json['promotionName'] as String? ?? '',
    );
  }
}

/// Estados posibles de una orden, tal como los define el backend
/// (models/orderModel.js).
enum OrderStatus {
  pending,
  confirmed,
  preparing,
  ready,
  outForDelivery,
  delivered,
  cancelled,
}

OrderStatus parseOrderStatus(String? raw) {
  switch (raw) {
    case 'CONFIRMED':
      return OrderStatus.confirmed;
    case 'PREPARING':
      return OrderStatus.preparing;
    case 'READY':
      return OrderStatus.ready;
    case 'OUT_FOR_DELIVERY':
      return OrderStatus.outForDelivery;
    case 'DELIVERED':
      return OrderStatus.delivered;
    case 'CANCELLED':
      return OrderStatus.cancelled;
    case 'PENDING':
    default:
      return OrderStatus.pending;
  }
}

/// "En local" (sin envío) o "Envío" (+$5.000). Valores del backend:
/// PICKUP | DELIVERY.
enum DeliveryType { pickup, delivery }

extension DeliveryTypeX on DeliveryType {
  String get apiValue => this == DeliveryType.pickup ? 'PICKUP' : 'DELIVERY';

  String get label => this == DeliveryType.pickup ? 'En local' : 'Envío';

  /// Solo para mostrar el resumen antes de confirmar; el backend
  /// calcula el valor real.
  double get shippingFee => this == DeliveryType.pickup ? 0 : 5000;
}

DeliveryType parseDeliveryType(String? raw) =>
    raw == 'PICKUP' ? DeliveryType.pickup : DeliveryType.delivery;

extension OrderStatusX on OrderStatus {
  /// Etiqueta en español para mostrar en la UI.
  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Pendiente';
      case OrderStatus.confirmed:
        return 'Confirmado';
      case OrderStatus.preparing:
        return 'Preparando';
      case OrderStatus.ready:
        return 'Listo';
      case OrderStatus.outForDelivery:
        return 'En camino';
      case OrderStatus.delivered:
        return 'Entregado';
      case OrderStatus.cancelled:
        return 'Cancelado';
    }
  }

  /// Valor que entiende el backend (PATCH /orders/:id/status).
  String get apiValue {
    switch (this) {
      case OrderStatus.pending:
        return 'PENDING';
      case OrderStatus.confirmed:
        return 'CONFIRMED';
      case OrderStatus.preparing:
        return 'PREPARING';
      case OrderStatus.ready:
        return 'READY';
      case OrderStatus.outForDelivery:
        return 'OUT_FOR_DELIVERY';
      case OrderStatus.delivered:
        return 'DELIVERED';
      case OrderStatus.cancelled:
        return 'CANCELLED';
    }
  }

  /// Estados desde los que el cliente aún puede cancelar (misma regla
  /// que orderController.cancelOrder; además hay ventana de 10 min).
  bool get isCancellable => this == OrderStatus.pending || this == OrderStatus.confirmed;

  bool get isFinal => this == OrderStatus.delivered || this == OrderStatus.cancelled;

  /// Siguientes estados que el admin puede aplicar. Refleja
  /// NEXT_STATUSES de orderController.js; el backend sigue siendo
  /// quien decide (esto solo evita mostrar botones que serían rechazados).
  List<OrderStatus> nextOptions(DeliveryType deliveryType) {
    switch (this) {
      case OrderStatus.pending:
        return [OrderStatus.confirmed, OrderStatus.cancelled];
      case OrderStatus.confirmed:
        return [OrderStatus.preparing, OrderStatus.cancelled];
      case OrderStatus.preparing:
        return [OrderStatus.ready, OrderStatus.cancelled];
      case OrderStatus.ready:
        return [
          deliveryType == DeliveryType.delivery ? OrderStatus.outForDelivery : OrderStatus.delivered,
          OrderStatus.cancelled,
        ];
      case OrderStatus.outForDelivery:
        return [OrderStatus.delivered, OrderStatus.cancelled];
      case OrderStatus.delivered:
      case OrderStatus.cancelled:
        return const [];
    }
  }
}

class Order {
  final String id;
  final List<OrderItemLine> items;
  final double subtotal;
  final double shippingCost;
  final double discount;
  final double total;
  final OrderStatus status;
  final String paymentStatus;
  final String notes;
  final DateTime? createdAt;

  final DeliveryType deliveryType;
  final String recipientName;
  final String recipientPhone;

  // Dirección de entrega (snapshot guardado en el pedido).
  final String addressLabel;
  final String addressText;

  // Método de pago (snapshot): título + detalle.
  final String paymentTitle;
  final String paymentDetail;

  // Cliente (solo viene poblado en GET /orders, vista admin).
  final String customerName;
  final String customerEmail;
  final String customerPhone;

  /// Momento límite para cancelar, calculado con los segundos que
  /// devuelve el servidor (así no depende del reloj del teléfono).
  final DateTime? cancelDeadline;

  Order({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.shippingCost,
    required this.discount,
    required this.total,
    required this.status,
    required this.paymentStatus,
    required this.notes,
    required this.createdAt,
    required this.deliveryType,
    required this.recipientName,
    required this.recipientPhone,
    required this.addressLabel,
    required this.addressText,
    required this.paymentTitle,
    required this.paymentDetail,
    this.customerName = '',
    this.customerEmail = '',
    this.customerPhone = '',
    this.cancelDeadline,
  });

  String get shortId {
    final shortId = id.length >= 6 ? id.substring(id.length - 6) : id;
    return shortId.toUpperCase();
  }

  /// Tiempo que le queda al cliente para cancelar (Duration.zero si ya
  /// no puede). El backend vuelve a validarlo al cancelar.
  Duration get cancelRemaining {
    if (!status.isCancellable || cancelDeadline == null) return Duration.zero;
    final remaining = cancelDeadline!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  bool get canCancel => cancelRemaining > Duration.zero;

  factory Order.fromJson(Map<String, dynamic> json) {
    // Dirección: snapshot del pedido; para pedidos antiguos (sin
    // snapshot) se usa la dirección poblada, si todavía existe.
    Map<String, dynamic>? addressMap = json['addressSnapshot'] as Map<String, dynamic>?;
    addressMap ??= json['addressId'] is Map<String, dynamic> ? json['addressId'] as Map<String, dynamic> : null;

    String addressLabel = '';
    String addressText = '';

    if (addressMap != null) {
      addressLabel = addressMap['label'] as String? ?? '';
      final parts = [
        addressMap['address'] as String? ?? '',
        addressMap['neighborhood'] as String? ?? '',
        addressMap['city'] as String? ?? '',
      ].where((s) => s.isNotEmpty);
      addressText = parts.join(', ');
    }

    String paymentTitle = '';
    String paymentDetail = '';
    final rawPayment = json['paymentSnapshot'];
    if (rawPayment is Map<String, dynamic> && (rawPayment['type'] as String? ?? '').isNotEmpty) {
      final method = PaymentMethod.fromJson(rawPayment);
      paymentTitle = method.displayTitle;
      paymentDetail = method.type == 'CARD' && method.lastFourDigits.isNotEmpty
          ? '•••• ${method.lastFourDigits}'
          : method.displaySubtitle;
    }

    String customerName = '';
    String customerEmail = '';
    String customerPhone = '';
    final rawUser = json['userId'];
    if (rawUser is Map<String, dynamic>) {
      customerName = [
        rawUser['name'] as String? ?? '',
        rawUser['lastName'] as String? ?? '',
      ].where((s) => s.isNotEmpty).join(' ');
      customerEmail = rawUser['email'] as String? ?? '';
      customerPhone = rawUser['phone'] as String? ?? '';
    }

    DateTime? createdAt;
    final rawDate = json['createdAt'];
    if (rawDate is String) {
      createdAt = DateTime.tryParse(rawDate)?.toLocal();
    }

    DateTime? cancelDeadline;
    final seconds = (json['cancelSecondsRemaining'] as num?)?.toInt();
    if (seconds != null && seconds > 0) {
      cancelDeadline = DateTime.now().add(Duration(seconds: seconds));
    }

    return Order(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      items: (json['items'] as List? ?? [])
          .map((e) => OrderItemLine.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      shippingCost: (json['shippingCost'] as num?)?.toDouble() ?? 0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      status: parseOrderStatus(json['status'] as String?),
      paymentStatus: json['paymentStatus'] as String? ?? 'PENDING',
      notes: json['notes'] as String? ?? '',
      createdAt: createdAt,
      deliveryType: parseDeliveryType(json['deliveryType'] as String?),
      recipientName: json['recipientName'] as String? ?? '',
      recipientPhone: json['recipientPhone'] as String? ?? '',
      addressLabel: addressLabel,
      addressText: addressText,
      paymentTitle: paymentTitle,
      paymentDetail: paymentDetail,
      customerName: customerName,
      customerEmail: customerEmail,
      customerPhone: customerPhone,
      cancelDeadline: cancelDeadline,
    );
  }
}
