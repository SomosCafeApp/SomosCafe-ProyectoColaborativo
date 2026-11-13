/// Datos de identidad de la app y del negocio que se muestran en los
/// documentos legales y en "Acerca de". Mantén `version` igual a la de
/// pubspec.yaml (version: X.Y.Z+N) cuando publiques una versión nueva.
class AppInfo {
  AppInfo._();

  static const String appName = 'SomosCafe App';
  static const String version = '1.0.0';
  static const String build = '1';
  static const String packageId = 'com.somoscafeapp';

  static const String businessName = 'Cafetería SOMOS';
  static const String location = 'Garzón, Huila, Colombia';

  /// Correo para asuntos legales, de datos personales y PQR.
  static const String legalEmail = 'legal@coffeeapp.co';

  /// Versión vigente de los Términos y de la Política de Privacidad.
  /// Se envía al backend como constancia al registrarse. Cámbiala cuando
  /// actualices esos textos.
  static const String termsVersion = '2026-11-13';
  static const String termsUpdated = '13 de noviembre de 2026';
}
