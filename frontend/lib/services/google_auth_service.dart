import 'package:google_sign_in/google_sign_in.dart';

/// Envuelve google_sign_in para obtener el idToken que el backend
/// espera en POST /api/users/login-google.
class GoogleAuthService {
  // TODO: reemplaza esto por tu Web Client ID de Google Cloud Console
  // (Credenciales > OAuth 2.0 Client IDs > tipo "Web application").
  // Debe ser el MISMO valor que tienes en GOOGLE_CLIENT_ID en el backend.
  static const String _webClientId =
      '868387662732-ftnmrqkac2b0qp7q6tgjb6vmi69birg2.apps.googleusercontent.com';

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    // En Web, `clientId` debe ser el Client ID tipo "Web application".
    // Si el día de mañana compilas para Android/iOS, ese mismo valor
    // se pasa como `serverClientId` (no `clientId`) para que el
    // idToken traiga la audiencia correcta que el backend verifica.
    clientId: _webClientId,
    scopes: ['email', 'profile'],
  );

  /// Abre el flujo de Google. Devuelve el idToken, o null si el
  /// usuario canceló el diálogo.
  ///
  /// Cierra la sesión de Google ANTES de abrir el selector: si no se
  /// hace esto, el plugin recuerda la última cuenta usada y el
  /// selector de cuentas ni siquiera aparece (te vuelve a loguear
  /// con la misma cuenta de la vez anterior).
  static Future<String?> signInAndGetIdToken() async {
    await _googleSignIn.signOut();

    final account = await _googleSignIn.signIn();
    if (account == null) return null;

    final auth = await account.authentication;
    return auth.idToken;
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
