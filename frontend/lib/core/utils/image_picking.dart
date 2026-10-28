import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/picked_image.dart';

/// Máximo que acepta el backend para una imagen (5 MB).
const int kMaxImageBytes = 5 * 1024 * 1024;

/// Abre la galería o la cámara y devuelve la imagen (bytes + nombre) lista
/// para subirla por multipart, o null si el usuario cancela o algo falla.
///
/// - Cancelar NO es un error: devuelve null sin mostrar ningún aviso.
/// - Si falta el permiso de cámara/galería, o no hay cámara, muestra un
///   aviso claro (en vez de fallar en silencio).
/// - Si la imagen supera [maxBytes] (el backend rechaza más de 5 MB),
///   avisa y devuelve null.
Future<PickedImage?> pickImage(
  BuildContext context, {
  required ImageSource source,
  double maxSide = 1600,
  int quality = 85,
  int maxBytes = kMaxImageBytes,
}) async {
  final messenger = ScaffoldMessenger.of(context);

  void warn(String message) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  try {
    final file = await ImagePicker().pickImage(
      source: source,
      maxWidth: maxSide,
      maxHeight: maxSide,
      imageQuality: quality,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (file == null) return null; // canceló

    return await pickedImageFromFile(file, maxBytes: maxBytes, onWarning: warn);
  } on PlatformException catch (e) {
    warn(imagePickErrorMessage(e, source));
    return null;
  } catch (_) {
    warn(source == ImageSource.camera
        ? 'No se pudo abrir la cámara. Inténtalo de nuevo.'
        : 'No se pudo abrir la galería. Inténtalo de nuevo.');
    return null;
  }
}

/// Atajo histórico: abre la galería (foto de perfil, comprobantes...).
Future<PickedImage?> pickGalleryImage(
  BuildContext context, {
  double maxSide = 1600,
  int quality = 85,
  int maxBytes = kMaxImageBytes,
}) =>
    pickImage(
      context,
      source: ImageSource.gallery,
      maxSide: maxSide,
      quality: quality,
      maxBytes: maxBytes,
    );

/// Convierte el archivo del selector en [PickedImage] validando el peso y
/// asegurando un nombre con extensión (el backend deduce el tipo de la
/// extensión; algunas cámaras entregan archivos sin ella).
Future<PickedImage?> pickedImageFromFile(
  XFile file, {
  int maxBytes = kMaxImageBytes,
  void Function(String message)? onWarning,
}) async {
  final bytes = await file.readAsBytes();

  if (bytes.isEmpty) {
    onWarning?.call('No se pudo leer la imagen. Elige otra.');
    return null;
  }

  if (bytes.length > maxBytes) {
    onWarning?.call('La imagen supera los 5 MB. Elige una más liviana.');
    return null;
  }

  return PickedImage(bytes: bytes, name: _nameWithExtension(file.name));
}

String _nameWithExtension(String name) {
  final clean = name.trim().isEmpty ? 'imagen' : name.trim();
  final dot = clean.lastIndexOf('.');
  final ext = dot == -1 ? '' : clean.substring(dot + 1).toLowerCase();
  const allowed = {'jpg', 'jpeg', 'png', 'webp', 'avif'};
  return allowed.contains(ext) ? clean : '$clean.jpg';
}

/// Mensaje claro para los errores de permisos y de cámara más comunes
/// (códigos de `image_picker` en Android e iOS).
String imagePickErrorMessage(PlatformException e, ImageSource source) {
  switch (e.code) {
    case 'camera_access_denied':
      return 'Sin permiso para usar la cámara. Actívalo en los ajustes del teléfono.';
    case 'camera_access_restricted':
      return 'El acceso a la cámara está restringido en este dispositivo.';
    case 'photo_access_denied':
      return 'Sin permiso para ver tus fotos. Actívalo en los ajustes del teléfono.';
    case 'photo_access_restricted':
      return 'El acceso a las fotos está restringido en este dispositivo.';
    case 'no_available_camera':
      return 'Este dispositivo no tiene una cámara disponible.';
    case 'already_active':
      return 'Ya hay un selector de imágenes abierto.';
    default:
      return source == ImageSource.camera
          ? 'No se pudo abrir la cámara. Inténtalo de nuevo.'
          : 'No se pudo abrir la galería. Inténtalo de nuevo.';
  }
}
