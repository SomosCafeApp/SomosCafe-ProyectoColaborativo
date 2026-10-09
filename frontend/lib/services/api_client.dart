import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' show MediaType;

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

  /// Lo registra AuthProvider: se llama cuando el backend responde que
  /// el token venció, para renovar la sesión sin que el usuario haga nada.
  static void Function()? onTokenExpired;

  // Subir una imagen a Cloudinary tarda más que una petición normal.
  static const Duration _uploadTimeout = Duration(seconds: 60);

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

  static Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    return _send(() => http
        .patch(
          Uri.parse('${ApiConfig.baseUrl}$path'),
          headers: _headers(token: token),
          body: jsonEncode(body ?? {}),
        )
        .timeout(_timeout));
  }

  /// Envía un formulario `multipart/form-data` (POST o PUT) con campos
  /// de texto y, opcionalmente, una imagen. Se usa para productos: el
  /// backend recibe la imagen en el campo `imagen` y la sube a Cloudinary.
  ///
  /// Recibe los bytes (no un File) para que funcione igual en móvil y web.
  static Future<Map<String, dynamic>> sendMultipart(
    String method,
    String path, {
    required Map<String, String> fields,
    List<int>? imageBytes,
    String? imageName,
    String? token,
  }) async {
    return _send(() async {
      final request = http.MultipartRequest(method, Uri.parse('${ApiConfig.baseUrl}$path'))
        ..fields.addAll(fields);

      if (token != null) request.headers['Authorization'] = 'Bearer $token';

      if (imageBytes != null) {
        final name = imageName ?? 'imagen.jpg';
        request.files.add(http.MultipartFile.fromBytes(
          'imagen',
          imageBytes,
          filename: name,
          // El backend (multer) rechaza lo que no declare un tipo de
          // imagen válido, así que lo deducimos de la extensión.
          contentType: _imageMediaType(name),
        ));
      }

      final streamed = await request.send();
      return http.Response.fromStream(streamed);
    }, timeout: _uploadTimeout);
  }

  static MediaType _imageMediaType(String filename) {
    final ext = filename.contains('.') ? filename.split('.').last.toLowerCase() : '';
    switch (ext) {
      case 'png':
        return MediaType('image', 'png');
      case 'webp':
        return MediaType('image', 'webp');
      case 'avif':
        return MediaType('image', 'avif');
      default:
        return MediaType('image', 'jpeg');
    }
  }

  static Future<Map<String, dynamic>> _send(
    Future<http.Response> Function() request, {
    Duration? timeout,
  }) async {
    http.Response response;

    try {
      response = timeout == null ? await request() : await request().timeout(timeout);
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

    if (response.statusCode == 401 &&
        ((data['message'] as String?) ?? '').toLowerCase().contains('expired token')) {
      // El token venció con la app abierta: pedimos renovarlo y el
      // usuario solo debe repetir la acción (en vez de ver el error crudo).
      onTokenExpired?.call();
      throw ApiException(
        'Tu sesión se estaba renovando. Intenta de nuevo en unos segundos.',
        statusCode: 401,
      );
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
