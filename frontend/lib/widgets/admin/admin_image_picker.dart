import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/image_picking.dart';
import '../../models/picked_image.dart';

/// Selector de imagen (productos, eventos): muestra la imagen actual (al
/// editar) o la recién elegida, y permite traerla de la GALERÍA o tomarla
/// con la CÁMARA. Entrega la imagen como bytes + nombre para subirla por
/// multipart.
///
/// - La vista previa se actualiza al elegir; se puede volver a elegir o
///   quitar la selección ([onCleared]) antes de guardar.
/// - Al editar, si no se elige nada nueva se conserva la imagen actual.
/// - Cancelar el selector no cambia nada ni muestra errores; los permisos
///   denegados y los fallos muestran un aviso claro.
class AdminImagePicker extends StatefulWidget {
  /// Imagen que ya tiene el elemento (URL de Cloudinary), si edita.
  final String? currentImageUrl;
  final PickedImage? picked;
  final ValueChanged<PickedImage> onPicked;

  /// Si se indica, aparece "Quitar selección" mientras hay una imagen nueva
  /// elegida (vuelve a la imagen actual, o a vacío al crear).
  final VoidCallback? onCleared;
  final String? errorText;

  const AdminImagePicker({
    super.key,
    required this.currentImageUrl,
    required this.picked,
    required this.onPicked,
    this.onCleared,
    this.errorText,
  });

  @override
  State<AdminImagePicker> createState() => _AdminImagePickerState();
}

class _AdminImagePickerState extends State<AdminImagePicker> {
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _recoverLostPhoto();
  }

  /// En Android, abrir la cámara puede hacer que el sistema cierre la app
  /// por falta de memoria; al volver, la foto tomada llega aquí.
  Future<void> _recoverLostPhoto() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      final lost = await ImagePicker().retrieveLostData();
      final file = lost.file;
      if (lost.isEmpty || file == null || !mounted) return;
      final image = await pickedImageFromFile(file);
      if (image != null && mounted) widget.onPicked(image);
    } catch (_) {
      // Sin datos perdidos o no soportado: no pasa nada.
    }
  }

  Future<void> _pick(ImageSource source) async {
    if (_busy) return;
    setState(() => _busy = true);
    final image = await pickImage(context, source: source);
    if (!mounted) return;
    setState(() => _busy = false);
    if (image != null) widget.onPicked(image);
  }

  /// Tocar la vista previa ofrece las dos opciones.
  Future<void> _chooseSource() async {
    if (_busy) return;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Tomar una foto'),
              subtitle: const Text('Usa la cámara del teléfono'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Elegir de la galería'),
              subtitle: const Text('Una foto que ya tengas guardada'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source != null) await _pick(source);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fill = isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final picked = widget.picked;
    final currentUrl = widget.currentImageUrl;

    Widget content;
    if (picked != null) {
      content = Image.memory(
        Uint8List.fromList(picked.bytes),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholder(subtitleColor, 'No se pudo mostrar la imagen'),
      );
    } else if (currentUrl != null && currentUrl.startsWith('http')) {
      content = Image.network(
        currentUrl,
        fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        errorBuilder: (_, _, _) => _placeholder(subtitleColor, 'No se pudo cargar la imagen actual'),
      );
    } else {
      content = _placeholder(subtitleColor, 'Toca para elegir una imagen');
    }

    final hasImage = picked != null || (currentUrl ?? '').isNotEmpty;
    final canClear = picked != null && widget.onCleared != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _busy ? null : _chooseSource,
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
                if (picked != null)
                  Positioned(
                    left: 10,
                    top: 10,
                    child: _badge('Nueva imagen', Icons.check_circle_rounded),
                  ),
                if (_busy)
                  Container(
                    color: Colors.black.withAlpha(90),
                    child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _busy ? null : () => _pick(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined, size: 18),
                label: const Text('Galería'),
                style: _buttonStyle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _busy ? null : () => _pick(ImageSource.camera),
                icon: const Icon(Icons.photo_camera_outlined, size: 18),
                label: const Text('Cámara'),
                style: _buttonStyle,
              ),
            ),
          ],
        ),
        if (canClear)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _busy ? null : widget.onCleared,
              icon: const Icon(Icons.undo_rounded, size: 16),
              label: Text(
                (currentUrl ?? '').isNotEmpty ? 'Quitar selección (conservar la actual)' : 'Quitar selección',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        if (!hasImage && widget.errorText == null)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 4),
            child: Text('JPG, PNG, WEBP o AVIF · máximo 5 MB', style: TextStyle(fontSize: 11, color: subtitleColor)),
          ),
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 6),
            child: Text(widget.errorText!, style: const TextStyle(fontSize: 12, color: Color(0xFFE53935))),
          ),
      ],
    );
  }

  ButtonStyle get _buttonStyle => OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: BorderSide(color: AppColors.primary.withAlpha(120)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      );

  Widget _badge(String text, IconData icon) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: Colors.black.withAlpha(150), borderRadius: BorderRadius.circular(16)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 6),
            Text(text, style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      );

  Widget _placeholder(Color color, String text) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_photo_alternate_outlined, size: 40, color: color),
            const SizedBox(height: 6),
            Text(text, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      );
}
