import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Error de inicio de sesión con Google con un mensaje ya listo para
/// mostrarle al usuario (el detalle técnico queda en la consola).
class GoogleAuthException implements Exception {
  final String message;
  const GoogleAuthException(this.message);

  @override
  String toString() => message;
}

/// Envuelve google_sign_in para obtener el idToken que el backend
/// espera en POST /api/users/login-google.
class GoogleAuthService {
  /// Client ID tipo "Web application". Es el MISMO valor que
  /// GOOGLE_CLIENT_ID en el backend (es la "audiencia" del idToken).
  static const String _webClientId =
      '868387662732-ftnmrqkac2b0qp7q6tgjb6vmi69birg2.apps.googleusercontent.com';

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Web: el Client ID web va en `clientId`.
    clientId: kIsWeb ? _webClientId : null,
    // Android/iOS: el Client ID web va en `serverClientId`. Así Google
    // emite un idToken cuya audiencia es la que verifica el backend.
    // (En Android, pasarlo como `clientId` NO funciona: se ignora y el
    // idToken llega vacío o el login falla con DEVELOPER_ERROR).
    serverClientId: kIsWeb ? null : _webClientId,
    scopes: const ['email', 'profile'],
  );

  /// Abre el flujo de Google. Devuelve el idToken, o null si el
  /// usuario canceló el diálogo. Lanza [GoogleAuthException] si algo
  /// falla (configuración, red, etc.).
  static Future<String?> signInAndGetIdToken() async {
    try {
      // Cierra la sesión previa para que siempre aparezca el selector
      // de cuentas (si no, reutiliza la última cuenta sin preguntar).
      try {
        await _googleSignIn.signOut();
      } catch (_) {}

      final account = await _googleSignIn.signIn();
      if (account == null) return null; // el usuario canceló

      final auth = await account.authentication;
      final idToken = auth.idToken;

      if (idToken == null || idToken.isEmpty) {
        debugPrint('[GoogleAuth] Google no devolvió idToken. '
            'Revisa serverClientId y el cliente OAuth de Android.');
        throw const GoogleAuthException(
          'Google no entregó el token de acceso. Revisa la configuración '
          'de Google en la app.',
        );
      }
      return idToken;
    } on GoogleAuthException {
      rethrow;
    } on PlatformException catch (e) {
      debugPrint('[GoogleAuth] PlatformException code=${e.code} '
          'message=${e.message} details=${e.details}');
      throw GoogleAuthException(_friendlyMessage(e));
    } catch (e) {
      debugPrint('[GoogleAuth] Error inesperado: $e');
      throw const GoogleAuthException('Error al conectar con Google');
    }
  }

  /// Traduce los códigos del plugin a algo comprensible.
  /// Devuelve la cadena vacía solo si el usuario canceló (no debería
  /// llegar aquí porque signIn() devuelve null en ese caso).
  static String _friendlyMessage(PlatformException e) {
    final raw = '${e.code} ${e.message} ${e.details}'.toLowerCase();

    // 10 = DEVELOPER_ERROR: el paquete + huella SHA-1 de la app no
    // coinciden con ningún cliente OAuth Android en Google Cloud.
    if (raw.contains('apiexception: 10') || raw.contains(' 10:')) {
      return 'Google rechazó la app (error 10). Falta registrar la huella '
          'SHA-1 de esta compilación en Google Cloud.';
    }
    // 12500 = fallo genérico de configuración (pantalla de
    // consentimiento, correo de soporte, Client ID mal puesto).
    if (raw.contains('12500')) {
      return 'Google no pudo iniciar sesión (error 12500). Revisa la '
          'pantalla de consentimiento OAuth y el Client ID.';
    }
    // 12501 = el usuario cerró el selector.
    if (raw.contains('12501') || raw.contains('canceled')) {
      return 'Inicio de sesión cancelado';
    }
    // 7 = sin red.
    if (e.code == 'network_error' || raw.contains('apiexception: 7')) {
      return 'Sin conexión. Revisa tu internet e inténtalo de nuevo.';
    }
    return 'Error al conectar con Google (${e.code})';
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}