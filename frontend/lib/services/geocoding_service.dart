import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geocoding/geocoding.dart' as native;
import 'package:http/http.dart' as http;

import '../core/config/maps_config.dart';
import '../core/config/service_area.dart';

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
      case 'OUT_OF_AREA':
        return 'No se encontró esa dirección en Garzón, Huila';
      case 'REQUEST_DENIED':
        // Google explica el motivo exacto en `error_message` (Geocoding
        // API sin habilitar, facturación inactiva, key restringida a
        // apps Android, etc.). Lo mostramos en vez de ocultarlo.
        final reason = (errorMessage ?? '').trim();
        return reason.isEmpty
            ? 'Google rechazó la petición (REQUEST_DENIED). Revisa la '
                'API key, que "Geocoding API" esté habilitada y que la '
                'facturación esté activa.'
            : 'Google rechazó la petición: $reason';
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

/// Convierte texto <-> coordenadas, SIEMPRE dentro de Garzón, Huila:
///   - A lo que escribe el usuario se le agrega "Garzón, Huila, Colombia",
///     así que una dirección sin ciudad nunca salta a otra ciudad.
///   - De los resultados posibles se elige el primero (el más parecido)
///     que realmente caiga dentro de la zona de servicio.
///
/// En Android/iOS se usa PRIMERO el geocodificador nativo del teléfono
/// (gratis, sin API key ni facturación). Google solo se consulta si el
/// nativo no encuentra nada y hay una key configurada. En web no existe
/// el nativo, así que ahí se usa Google directamente.
class GeocodingService {
  static const _baseUrl = 'https://maps.googleapis.com/maps/api/geocode/json';

  static bool get _googleConfigured =>
      MapsConfig.apiKey.isNotEmpty &&
      MapsConfig.apiKey != 'TU_GOOGLE_MAPS_API_KEY';

  static Future<GeocodeResult> fromAddress(String address) async {
    final query = ServiceArea.withCity(address);

    if (!kIsWeb) {
      final result = await _nativeFromAddress(query);
      if (result != null) return result;
      if (!_googleConfigured) throw GeocodingException('ZERO_RESULTS', null);
    }

    final results = await _fetchResults(Uri.parse(_baseUrl).replace(queryParameters: {
      'address': query,
      'key': MapsConfig.apiKey,
      // Sesga la búsqueda a la zona de servicio, a Colombia y en español.
      'bounds': ServiceArea.googleBounds,
      'region': 'co',
      'language': 'es',
    }));

    for (final r in results) {
      if (ServiceArea.contains(r.latitude, r.longitude)) return r;
    }
    throw GeocodingException('OUT_OF_AREA', null);
  }

  static Future<GeocodeResult> fromCoordinates(double lat, double lng) async {
    if (!kIsWeb) {
      final address = await _nativeAddressFor(lat, lng);
      if (address != null) {
        return GeocodeResult(
          latitude: lat,
          longitude: lng,
          formattedAddress: address,
        );
      }
      if (!_googleConfigured) throw GeocodingException('ZERO_RESULTS', null);
    }

    final results = await _fetchResults(Uri.parse(_baseUrl).replace(queryParameters: {
      'latlng': '$lat,$lng',
      'key': MapsConfig.apiKey,
      'language': 'es',
    }));

    if (results.isEmpty) throw GeocodingException('ZERO_RESULTS', null);
    return results.first;
  }

  // --------------------------------------------------
  // Geocodificador nativo (Android / iOS). Gratis, sin API key.
  // --------------------------------------------------

  static Future<GeocodeResult?> _nativeFromAddress(String query) async {
    try {
      await native.setLocaleIdentifier('es_CO');
      final locations = await native.locationFromAddress(query);

      // Solo resultados dentro de Garzón; el primero es el más parecido.
      final inArea = locations
          .where((l) => ServiceArea.contains(l.latitude, l.longitude))
          .toList();
      if (inArea.isEmpty) return null;

      final first = inArea.first;
      final formatted =
          await _nativeAddressFor(first.latitude, first.longitude) ??
              ServiceArea.stripCity(query);

      return GeocodeResult(
        latitude: first.latitude,
        longitude: first.longitude,
        formattedAddress: formatted,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<String?> _nativeAddressFor(double lat, double lng) async {
    try {
      await native.setLocaleIdentifier('es_CO');
      final marks = await native.placemarkFromCoordinates(lat, lng);
      if (marks.isEmpty) return null;

      final p = marks.first;
      final parts = <String>[];
      for (final part in [
        p.street,
        p.subLocality,
        p.locality,
        p.administrativeArea,
      ]) {
        final value = (part ?? '').trim();
        if (value.isNotEmpty && !parts.contains(value)) parts.add(value);
      }

      return parts.isEmpty ? null : ServiceArea.stripCity(parts.join(', '));
    } catch (_) {
      return null;
    }
  }

  // --------------------------------------------------
  // API HTTP de Google
  // --------------------------------------------------

  static Future<List<GeocodeResult>> _fetchResults(Uri uri) async {
    if (!_googleConfigured) {
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

    return (data['results'] as List).map((raw) {
      final item = raw as Map<String, dynamic>;
      final location = item['geometry']['location'] as Map<String, dynamic>;
      return GeocodeResult(
        latitude: (location['lat'] as num).toDouble(),
        longitude: (location['lng'] as num).toDouble(),
        formattedAddress:
            ServiceArea.stripCity(item['formatted_address'] as String? ?? ''),
      );
    }).toList();
  }
}
