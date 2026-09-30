/// Un producto dentro de una orden ya creada. A diferencia de
/// [Product], esto es una "foto" del producto en el momento de la
/// compra (nombre/precio pueden cambiar después y la orden no se ve
/// afectada), tal como lo guarda el backend en `order.items`.
class OrderItemLine {
  final String productId;
  final String name;
  final String image;
  final double price;
  final int quantity;
  final double subtotal;

  OrderItemLine({
    required this.productId,
    required this.name,
    required this.image,
    required this.price,
    required this.quantity,
    required this.subtotal,
  });

  factory OrderItemLine.fromJson(Map<String, dynamic> json) {
    return OrderItemLine(
      productId: (json['productId'] ?? '').toString(),
      name: json['name'] as String? ?? '',
      image: json['image'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
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

OrderStatus _parseStatus(String? raw) {
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

extension OrderStatusLabel on OrderStatus {
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

  /// Solo se puede cancelar mientras el backend no la haya empezado
  /// a preparar (misma regla que orderController.cancelOrder).
  bool get isCancellable => this == OrderStatus.pending || this == OrderStatus.confirmed;
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

  // Dirección de entrega (viene populada desde el backend).
  final String addressLabel;
  final String addressText;

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
    required this.addressLabel,
    required this.addressText,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    String addressLabel = '';
    String addressText = '';

    final rawAddress = json['addressId'];
    if (rawAddress is Map<String, dynamic>) {
      addressLabel = rawAddress['label'] as String? ?? '';
      final parts = [
        rawAddress['address'] as String? ?? '',
        rawAddress['neighborhood'] as String? ?? '',
        rawAddress['city'] as String? ?? '',
      ].where((s) => s.isNotEmpty);
      addressText = parts.join(', ');
    }

    DateTime? createdAt;
    final rawDate = json['createdAt'];
    if (rawDate is String) {
      createdAt = DateTime.tryParse(rawDate);
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
      status: _parseStatus(json['status'] as String?),
      paymentStatus: json['paymentStatus'] as String? ?? 'PENDING',
      notes: json['notes'] as String? ?? '',
      createdAt: createdAt,
      addressLabel: addressLabel,
      addressText: addressText,
    );
  }
}
