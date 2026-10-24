import 'package:url_launcher/url_launcher.dart';

import 'api_client.dart';
import 'api_exception.dart';

/// Contacto de soporte por WhatsApp. El número lo define el backend
/// (SUPPORT_WHATSAPP en su .env): la app nunca lo trae escrito.
class SupportContact {
  final bool available;
  final String? url;
  const SupportContact({required this.available, this.url});
}

class SupportService {
  SupportService._();

  static Future<SupportContact> fetchContact() async {
    final data = await ApiClient.get('/support/contact');
    final whatsapp = data['whatsapp'];
    if (whatsapp is Map && whatsapp['available'] == true) {
      return SupportContact(available: true, url: whatsapp['url'] as String?);
    }
    return const SupportContact(available: false);
  }

  /// Abre el chat de WhatsApp de soporte. Devuelve un mensaje de error
  /// para mostrar al usuario, o null si se abrió bien.
  static Future<String?> openWhatsApp() async {
    try {
      final contact = await fetchContact();
      final url = contact.url;
      if (!contact.available || url == null) {
        return 'El WhatsApp de soporte aún no está disponible.';
      }
      final opened = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      return opened ? null : 'No pudimos abrir WhatsApp en este dispositivo.';
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'No pudimos abrir WhatsApp. Inténtalo de nuevo.';
    }
  }
}
