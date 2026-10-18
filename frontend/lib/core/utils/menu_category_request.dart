/// Petición para abrir el Menú con una categoría ya seleccionada
/// (por ejemplo, al tocar una categoría en el Home).
///
/// [requestId] cambia en cada petición: así el Menú reacciona incluso si
/// el usuario toca la misma categoría dos veces seguidas.
class MenuCategoryRequest {
  /// Id de la categoría del Menú ('all', 'hot_coffee', 'cold_drinks'...).
  final String categoryId;
  final int requestId;

  const MenuCategoryRequest({
    required this.categoryId,
    required this.requestId,
  });
}
