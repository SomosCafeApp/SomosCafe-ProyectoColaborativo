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

/// Se lanza cuando Google responde algo distinto de "OK", para poder
/// mostrar el motivo real (key inválida, sin resultados, etc.) en
/// vez de fallar en silencio.
class GeocodingException implements Exception {
  final String status;
  final String? errorMessage;

  GeocodingException(this.status, this.errorMessage);

  @override
  String toString() {
    switch (status) {
      case 'ZERO_RESULTS':
        return 'No se encontró esa dirección';
      case 'REQUEST_DENIED':
        return 'La API key de Google Maps no es válida o le faltan '
            'permisos (revisa MapsConfig.apiKey y que "Geocoding API" '
            'esté habilitada)';
      case 'OVER_QUERY_LIMIT':
        return 'Se superó el límite de peticiones a Google Maps (revisa '
            'la facturación/cuota en Google Cloud Console)';
      case 'INVALID_REQUEST':
        return 'Petición inválida a Google Maps';
      default:
        return errorMessage ?? 'Error de Google Maps ($status)';
    }
  }
}

/// Usa la API HTTP de Google Geocoding directamente (en vez del
/// paquete `geocoding`, que no soporta Flutter Web) para:
///   - convertir un texto de dirección en coordenadas (forward)
///   - convertir coordenadas en una dirección legible (reverse),
///     útil cuando el usuario toca directamente sobre el mapa.
class GeocodingService {
  static const _baseUrl = 'https://maps.googleapis.com/maps/api/geocode/json';

  static Future<GeocodeResult> fromAddress(String address) async {
    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'address': address.trim(),
      'key': MapsConfig.apiKey,
    });
    return _fetchFirstResult(uri);
  }

  static Future<GeocodeResult> fromCoordinates(double lat, double lng) async {
    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'latlng': '$lat,$lng',
      'key': MapsConfig.apiKey,
    });
    return _fetchFirstResult(uri);
  }

  static Future<GeocodeResult> _fetchFirstResult(Uri uri) async {
    if (MapsConfig.apiKey.isEmpty || MapsConfig.apiKey == 'TU_GOOGLE_MAPS_API_KEY') {
      throw GeocodingException(
        'NO_API_KEY',
        'Falta configurar tu API key en lib/core/config/maps_config.dart',
      );
    }

    final response = await http.get(uri).timeout(const Duration(seconds: 10));
    final data = jsonDecode(response.body) as Map<String, dynamic>;

    final status = data['status'] as String? ?? 'UNKNOWN_ERROR';
    if (status != 'OK') {
      throw GeocodingException(status, data['error_message'] as String?);
    }

    final results = data['results'] as List;
    if (results.isEmpty) {
      throw GeocodingException('ZERO_RESULTS', null);
    }

    final first = results.first as Map<String, dynamic>;
    final location = first['geometry']['location'] as Map<String, dynamic>;

    return GeocodeResult(
      latitude: (location['lat'] as num).toDouble(),
      longitude: (location['lng'] as num).toDouble(),
      formattedAddress: first['formatted_address'] as String? ?? '',
    );
  }
}
