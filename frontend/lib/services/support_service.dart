import 'package:url_launcher/url_launcher.dart';

import 'api_client.dart';
import 'api_exception.dart';

/// Contacto de soporte por WhatsApp. El número y el mensaje inicial los
/// define el backend (SUPPORT_WHATSAPP y SUPPORT_WHATSAPP_MESSAGE en su
/// .env): la app nunca los trae escritos.
class SupportContact {
  final bool available;

  /// Enlace wa.me con el número (con indicativo) y el mensaje precargado.
  final String? url;

  /// Si no está disponible: `not_configured` (falta el número) o
  /// `invalid_number` (el número configurado no es válido).
  final String? reason;

  const SupportContact({required this.available, this.url, this.reason});
}

class SupportService {
  SupportService._();

  static const notConfiguredMessage =
      'El WhatsApp de soporte aún no está configurado. Mientras tanto, escríbenos desde el chat de ayuda.';
  static const invalidNumberMessage =
      'El número de WhatsApp de soporte no es válido. Avísale al administrador del negocio.';

  static Future<SupportContact> fetchContact() async {
    final data = await ApiClient.get('/support/contact');
    final whatsapp = data['whatsapp'];
    if (whatsapp is Map && whatsapp['available'] == true) {
      final url = whatsapp['url'];
      if (url is String && url.startsWith('https://wa.me/')) {
        return SupportContact(available: true, url: url);
      }
      return const SupportContact(available: false, reason: 'invalid_number');
    }
    final reason = whatsapp is Map ? whatsapp['reason'] as String? : null;
    return SupportContact(available: false, reason: reason ?? 'not_configured');
  }

  /// Abre el chat de WhatsApp de soporte (número con indicativo y mensaje
  /// ya escrito). Devuelve un mensaje de error para mostrar al usuario, o
  /// null si se abrió bien.
  static Future<String?> openWhatsApp() async {
    try {
      final contact = await fetchContact();
      final url = contact.url;
      if (!contact.available || url == null) {
        return contact.reason == 'invalid_number' ? invalidNumberMessage : notConfiguredMessage;
      }

      final uri = Uri.parse(url);

      // Primero la app de WhatsApp; si no está instalada, el navegador
      // abre wa.me, que ofrece instalarla o usar WhatsApp Web.
      var opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened) {
        opened = await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
      return opened ? null : 'No pudimos abrir WhatsApp en este dispositivo.';
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'No pudimos abrir WhatsApp. Inténtalo de nuevo.';
    }
  }
}
