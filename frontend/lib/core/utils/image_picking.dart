import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/picked_image.dart';

/// Abre la galería y devuelve la imagen elegida (bytes + nombre) lista
/// para subirla por multipart, o null si el usuario cancela.
///
/// Muestra un aviso si la imagen supera [maxBytes] (el backend rechaza
/// más de 5 MB) o si no se pudo abrir la galería.
Future<PickedImage?> pickGalleryImage(
  BuildContext context, {
  double maxSide = 1600,
  int quality = 85,
  int maxBytes = 5 * 1024 * 1024,
}) async {
  final messenger = ScaffoldMessenger.of(context);

  try {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: maxSide,
      maxHeight: maxSide,
      imageQuality: quality,
    );
    if (file == null) return null;

    final bytes = await file.readAsBytes();

    if (bytes.length > maxBytes) {
      messenger.showSnackBar(
        const SnackBar(content: Text('La imagen supera los 5 MB. Elige una más liviana.')),
      );
      return null;
    }

    return PickedImage(bytes: bytes, name: file.name);
  } catch (_) {
    messenger.showSnackBar(
      const SnackBar(content: Text('No se pudo abrir la galería')),
    );
    return null;
  }
}
