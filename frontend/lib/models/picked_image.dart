/// Imagen elegida desde la galería para subirla por multipart
/// (bytes + nombre, funciona igual en móvil y web).
class PickedImage {
  final List<int> bytes;
  final String name;

  const PickedImage({required this.bytes, required this.name});
}
