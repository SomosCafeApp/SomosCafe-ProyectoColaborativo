import '../../models/product_model.dart';

/// Los productos mejor calificados, para la sección "Lo Más Popular".
///
/// - Solo cuentan los productos con al menos una reseña (los demás
///   aparecen como "Nuevo" y todavía no tienen calificación real).
/// - Orden: mayor calificación primero. Si empatan, el que tiene más
///   reseñas (5.0 con 40 reseñas pesa más que 5.0 con una sola), luego
///   el más agregado a favoritos y, al final, por nombre para que el
///   resultado sea siempre el mismo.
List<Product> topRatedProducts(List<Product> products, {int limit = 4}) {
  final rated = products.where((p) => p.reviewCount > 0).toList()
    ..sort((a, b) {
      final byRating = b.rating.compareTo(a.rating);
      if (byRating != 0) return byRating;

      final byReviews = b.reviewCount.compareTo(a.reviewCount);
      if (byReviews != 0) return byReviews;

      final byFavorites = b.favoritesCount.compareTo(a.favoritesCount);
      if (byFavorites != 0) return byFavorites;

      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

  return rated.take(limit).toList();
}
