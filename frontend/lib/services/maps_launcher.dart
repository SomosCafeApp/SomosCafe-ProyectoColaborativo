import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Abre un lugar en Google Maps (app o navegador).
class MapsLauncher {
  MapsLauncher._();

  /// Enlace universal de Google Maps para buscar un lugar por texto.
  static Uri searchUri(String place) => Uri.https(
        'www.google.com',
        '/maps/search/',
        {'api': '1', 'query': place.trim()},
      );

  /// Devuelve null si abrió bien, o un mensaje de error para el usuario.
  static Future<String?> open(String place) async {
    if (place.trim().isEmpty) return 'Este evento no tiene una ubicación.';
    final uri = searchUri(place);
    try {
      var opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened) opened = await launchUrl(uri, mode: LaunchMode.platformDefault);
      return opened ? null : 'No pudimos abrir Google Maps.';
    } catch (_) {
      return 'No pudimos abrir Google Maps.';
    }
  }

  /// Abre y, si falla, avisa con el SnackBar estándar de la app.
  static Future<void> openWithFeedback(BuildContext context, String place) async {
    final messenger = ScaffoldMessenger.of(context);
    final error = await open(place);
    if (error != null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error)));
    }
  }
}
