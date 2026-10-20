/// Zona donde opera la app: solo Garzón, Huila.
///
/// Toda dirección se interpreta dentro de esta zona. Si algún día se
/// amplía el servicio, basta con cambiar estos valores.
class ServiceArea {
  static const String city = 'Garzón';
  static const String department = 'Huila';
  static const String country = 'Colombia';

  /// "Garzón, Huila, Colombia"
  static const String fullName = '$city, $department, $country';

  /// Centro aproximado del casco urbano de Garzón.
  static const double centerLat = 2.1967;
  static const double centerLng = -75.6275;

  /// Caja (suroeste / noreste) que delimita la zona de servicio. Es
  /// aproximada y generosa; ajústala si necesitas afinarla.
  static const double southLat = 2.10;
  static const double westLng = -75.72;
  static const double northLat = 2.30;
  static const double eastLng = -75.54;

  static bool contains(double lat, double lng) =>
      lat >= southLat && lat <= northLat && lng >= westLng && lng <= eastLng;

  /// Valor para el parámetro `bounds` de la API de Google Geocoding.
  static const String googleBounds =
      '$southLat,$westLng|$northLat,$eastLng';

  static String _normalize(String text) => text
      .toLowerCase()
      .replaceAll('ó', 'o')
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ú', 'u');

  /// Agrega "Garzón, Huila, Colombia" a lo que escribió el usuario para
  /// que nunca se busque en otra ciudad. Si ya lo menciona, no lo repite.
  static String withCity(String query) {
    final text = query.trim();
    if (_normalize(text).contains('garzon')) return '$text, $department, $country';
    return '$text, $fullName';
  }

  /// Quita el sufijo ", Garzón, Huila, Colombia" de una dirección ya
  /// resuelta para mostrarla corta (la ciudad es siempre la misma).
  static String stripCity(String address) {
    final stripped = address
        .replaceAll(
          RegExp(r',\s*Garz[óo]n\b.*$', caseSensitive: false),
          '',
        )
        .trim();
    // Si solo era la ciudad, mejor conservar el texto original.
    return stripped.isEmpty ? address.trim() : stripped;
  }
}
