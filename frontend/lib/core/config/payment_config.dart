/// Configuración del pago por transferencia.
class PaymentConfig {
  /// Imagen del código QR de la cafetería (el que recibe las
  /// transferencias). Para cambiarlo basta con reemplazar este archivo
  /// por el QR real, conservando el nombre; la carpeta assets/images/
  /// ya está declarada en pubspec.yaml.
  static const String qrAssetPath = 'assets/images/qr_pago.png';
}
