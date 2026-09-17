import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ApiConfig {
  // Backend local
  static const String _webUrl = 'http://localhost:3000/api';

  // Android físico conectado a la misma red que el PC
  static const String _androidUrl = 'http://192.168.137.1:3000/api';

  // Android Emulator
  static const String _emulatorUrl = 'http://10.0.2.2:3000/api';

  /// URL base de la API.
  static String get baseUrl {
    // Flutter Web / Chrome
    if (kIsWeb) {
      return _webUrl;
    }

    // Android
    if (defaultTargetPlatform == TargetPlatform.android) {
      return _androidUrl;
    }

    // iOS / Windows / macOS / Linux
    return _webUrl;
  }
}