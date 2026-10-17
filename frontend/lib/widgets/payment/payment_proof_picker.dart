import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/app_colors.dart';
import '../../models/picked_image.dart';

/// Selector de la captura del pago: elige la imagen de la galería y la
/// muestra completa (sin recortar) para que el cliente confirme que es
/// la correcta antes de enviarla.
class PaymentProofPicker extends StatelessWidget {
  final PickedImage? picked;
  final ValueChanged<PickedImage> onPicked;
  final bool enabled;

  const PaymentProofPicker({
    super.key,
    required this.picked,
    required this.onPicked,
    this.enabled = true,
  });

  // El backend acepta hasta 8 MB por comprobante.
  static const int _maxBytes = 8 * 1024 * 1024;

  Future<void> _pick(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (file == null) return;

      final bytes = await file.readAsBytes();

      if (bytes.length > _maxBytes) {
        messenger.showSnackBar(
          const SnackBar(content: Text('La imagen supera los 8 MB. Elige una más liviana.')),
        );
        return;
      }

      onPicked(PickedImage(bytes: bytes, name: file.name));
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('No se pudo abrir la galería')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fill = isDark ? AppColors.darkSurfaceSubtle : const Color(0xFFF6F6F6);
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    if (picked == null) {
      return InkWell(
        onTap: enabled ? () => _pick(context) : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withAlpha(120), width: 1.5),
          ),
          child: Column(
            children: [
              Icon(Icons.add_photo_alternate_outlined, size: 40, color: AppColors.primary),
              const SizedBox(height: 8),
              Text(
                'Elegir captura del pago',
                style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
              ),
              const SizedBox(height: 2),
              Text(
                'Toca para seleccionarla desde tu galería',
                style: TextStyle(fontSize: 12, color: subtitleColor),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxHeight: 360),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.memory(Uint8List.fromList(picked!.bytes), fit: BoxFit.contain),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: enabled ? () => _pick(context) : null,
          icon: Icon(Icons.swap_horiz_rounded, size: 18, color: AppColors.primary),
          label: Text('Cambiar imagen', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
