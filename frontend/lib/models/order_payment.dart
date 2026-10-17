/// Cómo paga el cliente. Valores del backend: CASH | TRANSFER.
///
/// - [cash]: paga al domiciliario (envío) o en la cafetería (en local).
/// - [transfer]: paga escaneando el QR y sube el comprobante.
enum PaymentMethodType { cash, transfer }

extension PaymentMethodTypeX on PaymentMethodType {
  String get apiValue => this == PaymentMethodType.cash ? 'CASH' : 'TRANSFER';

  String get label => this == PaymentMethodType.cash ? 'Efectivo' : 'Transferencia';
}

PaymentMethodType parsePaymentMethod(String? raw) =>
    raw == 'TRANSFER' ? PaymentMethodType.transfer : PaymentMethodType.cash;

/// Estado del pago, tal como lo define el backend (models/orderModel.js).
///
/// - [pending]: efectivo, se cobra al entregar o en el local.
/// - [awaitingProof]: transferencia, falta que el cliente suba el comprobante.
/// - [proofSubmitted]: comprobante subido, el admin debe revisarlo.
/// - [validated]: el admin validó el pago.
/// - [invalidated]: el admin lo invalidó (el pedido queda cancelado).
enum PaymentStatus { pending, awaitingProof, proofSubmitted, validated, invalidated }

/// Cualquier valor desconocido se trata como pendiente.
PaymentStatus parsePaymentStatus(String? raw) {
  switch (raw) {
    case 'AWAITING_PROOF':
      return PaymentStatus.awaitingProof;
    case 'PROOF_SUBMITTED':
      return PaymentStatus.proofSubmitted;
    case 'VALIDATED':
      return PaymentStatus.validated;
    case 'INVALIDATED':
      return PaymentStatus.invalidated;
    case 'PENDING':
    default:
      return PaymentStatus.pending;
  }
}

extension PaymentStatusX on PaymentStatus {
  /// Etiqueta en español para pagos por transferencia.
  String get label {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pendiente';
      case PaymentStatus.awaitingProof:
        return 'Falta el comprobante';
      case PaymentStatus.proofSubmitted:
        return 'Comprobante en revisión';
      case PaymentStatus.validated:
        return 'Pago validado';
      case PaymentStatus.invalidated:
        return 'Pago invalidado';
    }
  }
}
