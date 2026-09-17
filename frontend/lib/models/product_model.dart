class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final List<String> images;
  final List<String> ingredients;
  final double rating;
  final bool isAvailable;
  final bool isFavorite;
  final String? categoryId;
  final String? categoryName;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    List<String>? images,
    // Compatibilidad con el código existente que crea Product con imageUrl.
    String imageUrl = '',
    this.ingredients = const [],
    this.rating = 0,
    this.isAvailable = true,
    this.isFavorite = false,
    this.categoryId,
    this.categoryName,
  }) : images = images ?? (imageUrl.isNotEmpty ? [imageUrl] : const []);

  /// Primera imagen del producto, o cadena vacía si no tiene.
  /// Se mantiene por compatibilidad con widgets que ya usan `product.imageUrl`.
  String get imageUrl => images.isNotEmpty ? images.first : '';

  /// Crea un Product a partir de la respuesta del backend
  /// (GET /api/products y GET /api/products/:id).
  factory Product.fromJson(Map<String, dynamic> json) {
    // categoryId puede venir como string (sin populate) o como
    // objeto {_id, name, ...} (con populate, como hace el backend).
    String? categoryId;
    String? categoryName;
    final rawCategory = json['categoryId'];
    if (rawCategory is Map<String, dynamic>) {
      categoryId = rawCategory['_id']?.toString();
      categoryName = rawCategory['name'] as String?;
    } else if (rawCategory != null) {
      categoryId = rawCategory.toString();
    }

    return Product(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      images: (json['images'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      ingredients: (json['ingredients'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      isAvailable: json['isAvailable'] as bool? ?? true,
      categoryId: categoryId,
      categoryName: categoryName,
    );
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    List<String>? images,
    List<String>? ingredients,
    double? rating,
    bool? isAvailable,
    bool? isFavorite,
    String? categoryId,
    String? categoryName,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      images: images ?? this.images,
      ingredients: ingredients ?? this.ingredients,
      rating: rating ?? this.rating,
      isAvailable: isAvailable ?? this.isAvailable,
      isFavorite: isFavorite ?? this.isFavorite,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
    );
  }
}
