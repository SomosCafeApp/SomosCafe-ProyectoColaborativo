import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/picked_image.dart';

/// Selector de imagen del producto: muestra la imagen actual (al
/// editar) o la recién elegida, y abre la galería al tocarlo.
/// Entrega la imagen como bytes + nombre para subirla por multipart.
class ProductImagePicker extends StatelessWidget {
  /// Imagen que ya tiene el producto (URL de Cloudinary), si edita.
  final String? currentImageUrl;
  final PickedImage? picked;
  final ValueChanged<PickedImage> onPicked;
  final String? errorText;

  const ProductImagePicker({
    super.key,
    required this.currentImageUrl,
    required this.picked,
    required this.onPicked,
    this.errorText,
  });

  Future<void> _pick(BuildContext context) async {
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600, // el backend la reduce a 800 px; evitamos subir fotos enormes
        imageQuality: 85,
      );
      if (file == null) return;

      final bytes = await file.readAsBytes();

      // El backend rechaza imágenes de más de 5 MB.
      if (bytes.length > 5 * 1024 * 1024) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('La imagen supera los 5 MB. Elige una más liviana.')),
          );
        }
        return;
      }

      onPicked(PickedImage(bytes: bytes, name: file.name));
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir la galería')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fill = isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    Widget content;
    if (picked != null) {
      content = Image.memory(Uint8List.fromList(picked!.bytes), fit: BoxFit.cover);
    } else if (currentImageUrl != null && currentImageUrl!.startsWith('http')) {
      content = Image.network(
        currentImageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(subtitleColor),
      );
    } else {
      content = _placeholder(subtitleColor);
    }

    final hasImage = picked != null || (currentImageUrl ?? '').isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => _pick(context),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 170,
            width: double.infinity,
            decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(20)),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                content,
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(150),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.photo_library_outlined, size: 14, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          hasImage ? 'Cambiar imagen' : 'Elegir imagen',
                          style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 6),
            child: Text(errorText!, style: const TextStyle(fontSize: 12, color: Color(0xFFE53935))),
          ),
      ],
    );
  }

  Widget _placeholder(Color color) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_photo_alternate_outlined, size: 40, color: color),
            const SizedBox(height: 6),
            Text('Toca para elegir una imagen', style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      );
}
