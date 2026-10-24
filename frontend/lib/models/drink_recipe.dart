import 'product_customization.dart';

/// Receta del estudio de bebidas (reciente o guardada). Viene del
/// backend ya revalidada contra el menú actual: [available] es false
/// si la bebida o algún ingrediente ya no existen.
class DrinkRecipe {
  final String id;
  final String name;
  final bool isSaved;
  final DateTime? lastUsedAt;
  final String productId;
  final String? productName;
  final String? productImage;
  final double productPrice;
  final bool available;
  final double extraPrice;
  final double milkLevel;
  final ProductCustomization customization;

  const DrinkRecipe({
    required this.id,
    required this.name,
    required this.isSaved,
    required this.lastUsedAt,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.productPrice,
    required this.available,
    required this.extraPrice,
    required this.milkLevel,
    required this.customization,
  });

  /// Nombre para mostrar: el que le puso el usuario o el de la bebida.
  String get title => name.isNotEmpty ? name : (productName ?? 'Bebida');

  double get totalPrice => productPrice + extraPrice;

  factory DrinkRecipe.fromJson(Map<String, dynamic> json) {
    final product = json['product'] is Map ? json['product'] as Map : null;
    final custom = json['customization'] is Map ? Map<String, dynamic>.from(json['customization'] as Map) : null;
    return DrinkRecipe(
      id: (json['id'] ?? '').toString(),
      name: json['name'] as String? ?? '',
      isSaved: json['isSaved'] == true,
      lastUsedAt: DateTime.tryParse(json['lastUsedAt']?.toString() ?? ''),
      productId: (json['productId'] ?? '').toString(),
      productName: product?['name'] as String?,
      productImage: product?['image'] as String?,
      productPrice: (product?['price'] as num?)?.toDouble() ?? 0,
      available: json['available'] == true,
      extraPrice: (json['extraPrice'] as num?)?.toDouble() ?? 0,
      milkLevel: ((custom?['milkLevel'] as num?)?.toDouble() ?? 0.55).clamp(0.0, 1.0).toDouble(),
      customization: ProductCustomization.fromJson(custom),
    );
  }
}
