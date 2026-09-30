/// Método de pago guardado del usuario (GET/POST/PUT/DELETE /api/payment-methods).
class PaymentMethod {
  final String id;
  final String type; // CARD | CASH | BANK_TRANSFER | DIGITAL_WALLET
  final String provider;
  final String name;
  final String lastFourDigits;
  final int? expirationMonth;
  final int? expirationYear;
  final bool isDefault;

  PaymentMethod({
    required this.id,
    required this.type,
    this.provider = '',
    this.name = '',
    this.lastFourDigits = '',
    this.expirationMonth,
    this.expirationYear,
    this.isDefault = false,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      type: json['type'] as String? ?? 'CARD',
      provider: json['provider'] as String? ?? '',
      name: json['name'] as String? ?? '',
      lastFourDigits: json['lastFourDigits'] as String? ?? '',
      expirationMonth: (json['expirationMonth'] as num?)?.toInt(),
      expirationYear: (json['expirationYear'] as num?)?.toInt(),
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  /// Título legible según el tipo, listo para mostrar en tarjetas.
  String get displayTitle {
    switch (type) {
      case 'CARD':
        return name.isNotEmpty ? name : 'Tarjeta';
      case 'CASH':
        return 'Efectivo';
      case 'BANK_TRANSFER':
        return provider.isNotEmpty ? provider : 'Transferencia bancaria';
      case 'DIGITAL_WALLET':
        return provider.isNotEmpty ? provider : 'Billetera digital';
      default:
        return 'Método de pago';
    }
  }

  /// Subtítulo descriptivo según el tipo.
  String get displaySubtitle {
    switch (type) {
      case 'CARD':
        return lastFourDigits.isNotEmpty ? '**** **** **** $lastFourDigits' : 'Tarjeta guardada';
      case 'CASH':
        return 'Pago contra entrega';
      case 'BANK_TRANSFER':
        return 'Transferencia instantánea';
      case 'DIGITAL_WALLET':
        return 'Pago rápido';
      default:
        return '';
    }
  }
}
