class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final List<String> images;
  final List<String> ingredients;
  final double rating;
  // Cantidad de reseñas visibles usadas para calcular `rating`.
  final int reviewCount;
  // Cantidad de usuarios que tienen este producto en favoritos.
  final int favoritesCount;
  final bool isAvailable;
  final bool isFavorite;
  final String? categoryId;
  final String? categoryName;

  /// Precio con la promoción vigente (calculado por el backend), o
  /// null si el producto no tiene promoción. El descuento aplica al
  /// precio base; las personalizaciones se suman sin descuento.
  final double? discountedPrice;

  /// Nombre de la promoción aplicada, ej. "2x1 Capuchinos".
  final String? promotionName;

  /// Etiqueta corta del descuento, ej. "30% OFF" o "\$2.000 OFF".
  final String? promotionLabel;

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
    this.reviewCount = 0,
    this.favoritesCount = 0,
    this.isAvailable = true,
    this.isFavorite = false,
    this.categoryId,
    this.categoryName,
    this.discountedPrice,
    this.promotionName,
    this.promotionLabel,
  }) : images = images ?? (imageUrl.isNotEmpty ? [imageUrl] : const []);

  /// Primera imagen del producto, o cadena vacía si no tiene.
  /// Se mantiene por compatibilidad con widgets que ya usan `product.imageUrl`.
  String get imageUrl => images.isNotEmpty ? images.first : '';

  // Categorías cuyo nombre contiene alguna de estas palabras (postres)
  // no tienen menú de personalización. El backend lo aplica igual y
  // ignora cualquier personalización enviada para estos productos.
  static const List<String> _nonCustomizableKeywords = [
    'postre',
    'dessert',
    'torta',
    'pastel',
    'cheesecake',
  ];

  bool get isCustomizable {
    final name = (categoryName ?? '').toLowerCase();
    if (name.isEmpty) return true;
    return !_nonCustomizableKeywords.any(name.contains);
  }

  /// Ingredientes como texto libre separado por comas (para el formulario).
  String get ingredientsText => ingredients.join(', ');

  bool get hasDiscount => discountedPrice != null && discountedPrice! < price;

  /// Lo que realmente se paga por el producto base (sin personalización).
  double get effectivePrice => hasDiscount ? discountedPrice! : price;

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

    String? promotionName;
    String? promotionLabel;
    final rawPromotion = json['activePromotion'];
    if (rawPromotion is Map<String, dynamic>) {
      promotionName = rawPromotion['name'] as String?;
      final value = (rawPromotion['discountValue'] as num?)?.toDouble() ?? 0;
      promotionLabel = rawPromotion['discountType'] == 'percentage'
          ? '${value.toStringAsFixed(value % 1 == 0 ? 0 : 1)}% OFF'
          : '\$${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')} OFF';
    }

    return Product(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      images: (json['images'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      ingredients: (json['ingredients'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      favoritesCount: (json['favoritesCount'] as num?)?.toInt() ?? 0,
      isAvailable: json['isAvailable'] as bool? ?? true,
      categoryId: categoryId,
      categoryName: categoryName,
      discountedPrice: (json['discountedPrice'] as num?)?.toDouble(),
      promotionName: promotionName,
      promotionLabel: promotionLabel,
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
    int? reviewCount,
    int? favoritesCount,
    bool? isAvailable,
    bool? isFavorite,
    String? categoryId,
    String? categoryName,
    double? discountedPrice,
    String? promotionName,
    String? promotionLabel,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      images: images ?? this.images,
      ingredients: ingredients ?? this.ingredients,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      favoritesCount: favoritesCount ?? this.favoritesCount,
      isAvailable: isAvailable ?? this.isAvailable,
      isFavorite: isFavorite ?? this.isFavorite,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      promotionName: promotionName ?? this.promotionName,
      promotionLabel: promotionLabel ?? this.promotionLabel,
    );
  }
}
