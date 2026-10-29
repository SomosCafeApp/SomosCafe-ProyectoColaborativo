import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';

/// Guarda en la galería la imagen del widget envuelto en el
/// [RepaintBoundary] de [boundaryKey] (el latte terminado de DrinkStudio).
///
/// Es una acción del minijuego, SEPARADA de las compras: no toca el
/// carrito, los pedidos ni ningún producto. Devuelve el mensaje listo
/// para mostrar (éxito o motivo del fallo); nunca lanza.
Future<String> saveBoundaryToGallery(GlobalKey boundaryKey) async {
  if (kIsWeb) {
    return 'Guardar en la galería está disponible en la app móvil.';
  }

  try {
    final boundary = boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return 'No se pudo capturar tu latte. Inténtalo de nuevo.';

    if (!await Gal.hasAccess()) {
      if (!await Gal.requestAccess()) {
        return 'Permite el acceso a tus fotos para poder guardar tu latte.';
      }
    }

    final image = await boundary.toImage(pixelRatio: 3);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    if (data == null) return 'No se pudo capturar tu latte. Inténtalo de nuevo.';

    await Gal.putImageBytes(data.buffer.asUint8List());
    return 'Tu latte se guardó en la galería';
  } catch (_) {
    return 'No se pudo guardar. Intenta de nuevo o haz una captura de pantalla.';
  }
}
