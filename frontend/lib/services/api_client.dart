import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import 'api_exception.dart';

/// Wrapper delgado sobre `package:http` que:
/// - arma la URL completa a partir de [ApiConfig.baseUrl]
/// - agrega el header de autenticación cuando hay token
/// - decodifica el JSON de respuesta
/// - convierte cualquier error (de red o del backend) en [ApiException]
///   con el mensaje que el backend ya trae en `message`
class ApiClient {
  static const Duration _timeout = Duration(seconds: 15);

  static Map<String, String> _headers({String? token}) => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  static Future<Map<String, dynamic>> get(
    String path, {
    String? token,
  }) async {
    return _send(() => http
        .get(Uri.parse('${ApiConfig.baseUrl}$path'), headers: _headers(token: token))
        .timeout(_timeout));
  }

  static Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    return _send(() => http
        .post(
          Uri.parse('${ApiConfig.baseUrl}$path'),
          headers: _headers(token: token),
          body: jsonEncode(body ?? {}),
        )
        .timeout(_timeout));
  }

  static Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    return _send(() => http
        .put(
          Uri.parse('${ApiConfig.baseUrl}$path'),
          headers: _headers(token: token),
          body: jsonEncode(body ?? {}),
        )
        .timeout(_timeout));
  }

  static Future<Map<String, dynamic>> delete(
    String path, {
    String? token,
  }) async {
    return _send(() => http
        .delete(Uri.parse('${ApiConfig.baseUrl}$path'), headers: _headers(token: token))
        .timeout(_timeout));
  }

  static Future<Map<String, dynamic>> _send(
    Future<http.Response> Function() request,
  ) async {
    http.Response response;

    try {
      response = await request();
    } on TimeoutException {
      throw ApiException(
        'El servidor tardó demasiado en responder. ¿Está corriendo el backend?',
      );
    } catch (_) {
      throw ApiException(
        'No se pudo conectar con el servidor. Verifica que el backend '
        'esté corriendo en ${ApiConfig.baseUrl}.',
      );
    }

    Map<String, dynamic> data;
    try {
      data = response.body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      data = <String, dynamic>{};
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        (data['message'] as String?) ?? 'Ocurrió un error inesperado',
        statusCode: response.statusCode,
      );
    }

    return data;
  }
}
