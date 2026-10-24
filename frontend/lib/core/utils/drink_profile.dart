import 'package:flutter/material.dart';

import '../../models/drink_options.dart';
import '../../models/product_model.dart';

/// Qué mecánicas tienen sentido para una bebida concreta. Se deduce
/// del nombre y la categoría reales del producto con las palabras
/// clave que manda el backend, así no todas las bebidas juegan igual:
/// un té no lleva shots de espresso ni latte art.
class DrinkProfile {
  /// Lleva espresso: habilita la etapa de shots.
  final bool isCoffee;

  /// Lleva espuma de leche: habilita el latte art (si es caliente).
  final bool supportsLatteArt;

  /// Color decorativo del líquido base (solo pintura, no es un dato).
  final Color baseColor;

  const DrinkProfile({
    required this.isCoffee,
    required this.supportsLatteArt,
    required this.baseColor,
  });

  static Color _baseColorFor(String text) {
    if (text.contains('chocolate') || text.contains('cacao')) return const Color(0xFF5B3A29);
    if (text.contains('té') || text.contains(' tea') || text.startsWith('tea') || text.contains('chai')) {
      return const Color(0xFFC98B3E);
    }
    return const Color(0xFF4A2C1B);
  }

  /// Color decorativo de cada leche (solo pintura).
  static Color milkColorFor(String milk) {
    final m = milk.toLowerCase();
    if (m.contains('avena')) return const Color(0xFFE9D8B8);
    if (m.contains('almendra')) return const Color(0xFFEFE2CA);
    if (m.contains('soya') || m.contains('soja')) return const Color(0xFFF1E6C6);
    return const Color(0xFFF7EEDC);
  }

  factory DrinkProfile.of(Product product, DrinkOptions options) {
    final text = '${product.name} ${product.categoryName ?? ''}'.toLowerCase();
    bool has(List<String> keywords) => keywords.any(text.contains);
    return DrinkProfile(
      isCoffee: has(options.coffeeKeywords),
      supportsLatteArt: has(options.latteArtKeywords),
      baseColor: _baseColorFor(text),
    );
  }
}
