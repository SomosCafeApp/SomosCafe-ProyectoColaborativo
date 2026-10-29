import 'picked_image.dart';

/// Resultado de la pantalla de selección de avatar: UNO de los dos.
///  - [presetKey]: uno de los cinco avatares de Somos Café.
///  - [image]: foto elegida de la galería (ya validada en peso y tipo).
class AvatarChoice {
  final String? presetKey;
  final PickedImage? image;

  const AvatarChoice.preset(String key)
      : presetKey = key,
        image = null;

  const AvatarChoice.photo(PickedImage picked)
      : image = picked,
        presetKey = null;

  bool get isPreset => presetKey != null;
  bool get isPhoto => image != null;
}
