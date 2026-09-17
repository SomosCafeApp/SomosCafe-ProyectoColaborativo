/// Excepción lanzada cuando el backend responde con un error,
/// o cuando no fue posible conectarse a él.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  /// true si el backend contestó (aunque con error), false si
  /// el problema fue de red/conexión (backend apagado, sin internet, etc.)
  bool get isNetworkError => statusCode == null;

  @override
  String toString() => message;
}
