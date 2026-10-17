import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';

import '../core/config/payment_config.dart';

/// Guarda el QR de pago en la galería del teléfono para que el cliente
/// pueda cargarlo desde su app bancaria (la mayoría permite escanear un
/// QR desde una imagen guardada).
class PaymentQrService {
  /// Devuelve el mensaje listo para mostrar al usuario (éxito o motivo
  /// del fallo); nunca lanza.
  static Future<String> saveToGallery() async {
    if (kIsWeb) {
      return 'La descarga está disponible en la app móvil. Desde aquí puedes escanear el QR con tu celular.';
    }

    try {
      final data = await rootBundle.load(PaymentConfig.qrAssetPath);

      if (!await Gal.hasAccess()) {
        if (!await Gal.requestAccess()) {
          return 'Permite el acceso a tus fotos para poder guardar el QR.';
        }
      }

      await Gal.putImageBytes(data.buffer.asUint8List());
      return 'QR guardado en tu galería';
    } catch (_) {
      return 'No se pudo guardar el QR. Intenta de nuevo o haz una captura de pantalla.';
    }
  }
}
