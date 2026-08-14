class Product {
  final String id;
  final String name;
  final String description; // <-- Campo para la reseña o descripción
  final double price;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });
}