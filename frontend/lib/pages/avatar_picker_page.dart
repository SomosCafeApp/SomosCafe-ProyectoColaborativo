import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/utils/image_picking.dart';
import '../models/avatar_choice.dart';
import '../models/picked_image.dart';
import '../widgets/common/avatar_art.dart';
import '../widgets/common/user_avatar.dart';
import '../widgets/profile/profile_sub_page_header.dart';

/// Selección de avatar: cinco avatares de Somos Café o una foto de la
/// galería. Muestra vista previa, valida la imagen (peso, formato,
/// que se pueda abrir) y maneja los permisos con avisos claros.
///
/// No guarda nada por sí sola: devuelve un [AvatarChoice] al confirmar
/// o null si se cancela, así que cancelar nunca pierde el avatar actual.
class AvatarPickerPage extends StatefulWidget {
  /// Avatar actual (para mostrar de partida y detectar cambios).
  final String currentPreset;
  final String currentImageUrl;
  final String initials;

  const AvatarPickerPage({
    super.key,
    this.currentPreset = '',
    this.currentImageUrl = '',
    this.initials = 'U',
  });

  static Future<AvatarChoice?> open(
    BuildContext context, {
    String currentPreset = '',
    String currentImageUrl = '',
    String initials = 'U',
  }) {
    return Navigator.of(context).push<AvatarChoice>(
      MaterialPageRoute(
        builder: (_) => AvatarPickerPage(
          currentPreset: currentPreset,
          currentImageUrl: currentImageUrl,
          initials: initials,
        ),
      ),
    );
  }

  @override
  State<AvatarPickerPage> createState() => _AvatarPickerPageState();
}

class _AvatarPickerPageState extends State<AvatarPickerPage> {
  String? _selectedPreset;
  PickedImage? _pickedImage;
  bool _loadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _selectedPreset = AvatarPresets.isValid(widget.currentPreset) ? widget.currentPreset : null;
  }

  bool get _hasNewSelection {
    if (_pickedImage != null) return true;
    return _selectedPreset != null && _selectedPreset != widget.currentPreset;
  }

  Future<bool> _isDecodable(Uint8List bytes) async {
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      frame.image.dispose();
      codec.dispose();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _pickFromGallery() async {
    if (_loadingPhoto) return;
    setState(() => _loadingPhoto = true);

    // pickGalleryImage ya valida el peso (máx. 5 MB) y avisa si falta
    // el permiso de fotos o la galería no se puede abrir.
    final image = await pickGalleryImage(context, maxSide: 800);
    if (!mounted) return;

    if (image == null) {
      setState(() => _loadingPhoto = false);
      return;
    }

    final ok = await _isDecodable(Uint8List.fromList(image.bytes));
    if (!mounted) return;

    if (!ok) {
      setState(() => _loadingPhoto = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Ese archivo no es una imagen válida. Elige otra.')));
      return;
    }

    setState(() {
      _pickedImage = image;
      _selectedPreset = null;
      _loadingPhoto = false;
    });
  }

  void _selectPreset(String key) {
    setState(() {
      _selectedPreset = key;
      _pickedImage = null;
    });
  }

  Widget _preview(double size) {
    final border = Border.all(color: AppColors.primary.withAlpha(90), width: 3);

    if (_pickedImage != null) {
      return Container(
        width: size,
        height: size,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(shape: BoxShape.circle, border: border),
        child: Image.memory(Uint8List.fromList(_pickedImage!.bytes), fit: BoxFit.cover),
      );
    }

    return UserAvatar(
      imageUrl: _selectedPreset == null ? widget.currentImageUrl : '',
      initials: widget.initials,
      avatarPreset: _selectedPreset ?? '',
      size: size,
      fontSize: size * 0.34,
      border: border,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          const ProfileSubPageHeader(
            title: 'Elige tu avatar',
            subtitle: 'Así te verán en la app',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                children: [
                  Semantics(
                    label: 'Vista previa de tu avatar',
                    child: _preview(132),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _pickedImage != null
                        ? 'Tu foto'
                        : _selectedPreset != null
                            ? AvatarPresets.nameOf(_selectedPreset!)
                            : 'Sin avatar',
                    style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Avatares de Somos Café',
                        style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: [
                      for (final preset in AvatarPresets.all)
                        _Tile(
                          label: preset.name,
                          selected: _selectedPreset == preset.key,
                          surface: surface,
                          textColor: textColor,
                          onTap: () => _selectPreset(preset.key),
                          child: AvatarArt(presetKey: preset.key, size: 64),
                        ),
                      _Tile(
                        label: 'Galería',
                        selected: _pickedImage != null,
                        surface: surface,
                        textColor: textColor,
                        onTap: _loadingPhoto ? null : _pickFromGallery,
                        child: _loadingPhoto
                            ? const SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.primary),
                              )
                            : const Icon(Icons.photo_library_outlined, size: 32, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Para usar una foto, toca «Galería». Máximo 5 MB (JPG, PNG o WEBP).',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: subColor, fontSize: 12.5),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        backgroundColor: AppColors.primary,
                      ),
                      onPressed: !_hasNewSelection
                          ? null
                          : () => Navigator.of(context).pop(
                                _pickedImage != null
                                    ? AvatarChoice.photo(_pickedImage!)
                                    : AvatarChoice.preset(_selectedPreset!),
                              ),
                      child: const Text('Usar este avatar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final String label;
  final bool selected;
  final Color surface;
  final Color textColor;
  final VoidCallback? onTap;
  final Widget child;

  const _Tile({
    required this.label,
    required this.selected,
    required this.surface,
    required this.textColor,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          width: 96,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? AppColors.primary : Colors.transparent,
              width: 2.5,
            ),
          ),
          child: Column(
            children: [
              SizedBox(width: 64, height: 64, child: Center(child: child)),
              const SizedBox(height: 6),
              Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
