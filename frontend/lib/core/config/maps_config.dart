/// Clave de Google Geocoding (servicio web).
///
/// Ya NO se guarda en el repositorio. Se inyecta al compilar:
///
///   flutter run --dart-define=GEOCODING_API_KEY=tu_clave
///   flutter build apk --release --dart-define=GEOCODING_API_KEY=tu_clave
///
/// Si no se define, la app usa el geocodificador nativo del teléfono.
class MapsConfig {
  static const String apiKey =
      String.fromEnvironment('GEOCODING_API_KEY', defaultValue: '');
}
