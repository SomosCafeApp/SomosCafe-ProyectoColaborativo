
import 'package:flutter/foundation.dart';

class ApiConfig {
  // Cambia a false para utilizar el backend local.
  static const bool useRemote = true;

  // Backend desplegado en Render.
  static const String _remoteUrl =
      'https://somoscafe-app.onrender.com/api';

  // Backend local para Flutter Web / Chrome.
  static const String _webUrl =
      'http://localhost:3000/api';

  // Backend local para el emulador Android.
  static const String _androidUrl =
      'http://10.0.2.2:3000/api';

  /// URL base de la API.
  static String get baseUrl {
    // Si useRemote es true, utiliza Render en todas las plataformas.
    if (useRemote) {
      return _remoteUrl;
    }

    // Si useRemote es false, utiliza el backend local.
    if (kIsWeb) {
      return _webUrl;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return _androidUrl;
    }

    // iOS / Windows / macOS / Linux.
    return _webUrl;
  }
}
