import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/config/maps_config.dart';

/// Resultado de geocodificar (o revertir) una dirección.
class GeocodeResult {
  final double latitude;
  final double longitude;
  final String formattedAddress;

  GeocodeResult({
    required this.latitude,
    required this.longitude,
    required this.formattedAddress,
  });
}

/// Usa la API HTTP de Google Geocoding directamente (en vez del
/// paquete `geocoding`, que no soporta Flutter Web) para:
///   - convertir un texto de dirección en coordenadas (forward)
///   - convertir coordenadas en una dirección legible (reverse),
///     útil cuando el usuario toca directamente sobre el mapa.
class GeocodingService {
  static const _baseUrl = 'https://maps.googleapis.com/maps/api/geocode/json';

  static Future<GeocodeResult?> fromAddress(String address) async {
    if (address.trim().isEmpty) return null;

    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'address': address.trim(),
      'key': MapsConfig.apiKey,
    });

    return _fetchFirstResult(uri);
  }

  static Future<GeocodeResult?> fromCoordinates(double lat, double lng) async {
    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'latlng': '$lat,$lng',
      'key': MapsConfig.apiKey,
    });

    return _fetchFirstResult(uri);
  }

  static Future<GeocodeResult?> _fetchFirstResult(Uri uri) async {
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      final status = data['status'] as String?;
      if (status != 'OK') return null;

      final results = data['results'] as List;
      if (results.isEmpty) return null;

      final first = results.first as Map<String, dynamic>;
      final location = first['geometry']['location'] as Map<String, dynamic>;

      return GeocodeResult(
        latitude: (location['lat'] as num).toDouble(),
        longitude: (location['lng'] as num).toDouble(),
        formattedAddress: first['formatted_address'] as String? ?? '',
      );
    } catch (_) {
      return null;
    }
  }
}
