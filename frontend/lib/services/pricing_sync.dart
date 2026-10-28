import '../models/drink_options.dart';
import 'api_client.dart';

/// Descarga UNA vez las tablas de precios del servidor
/// (`GET /customization/options`) y las registra en
/// `ProductCustomization`. Así el detalle, el carrito optimista y el
/// estudio calculan con los mismos valores que cobra el backend. Si no
/// hay conexión se siguen usando los valores de respaldo de la app.
class PricingSync {
  PricingSync._();

  static bool _loaded = false;
  static Future<bool>? _inFlight;

  /// true cuando las tablas del servidor ya están registradas.
  static bool get isLoaded => _loaded;

  static Future<bool> ensureLoaded() {
    if (_loaded) return Future.value(true);
    return _inFlight ??= _load();
  }

  static Future<bool> _load() async {
    try {
      final data = await ApiClient.get('/customization/options');
      DrinkOptions.fromJson(data['options'] as Map<String, dynamic>).register();
      _loaded = true;
    } catch (_) {
      _loaded = false;
    }
    _inFlight = null;
    return _loaded;
  }
}
