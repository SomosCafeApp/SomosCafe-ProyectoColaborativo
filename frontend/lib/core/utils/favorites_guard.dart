import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/product_provider.dart';

/// Centraliza la regla "hay que estar logueado para marcar favoritos".
/// Se usa en vez de llamar a FavoritesProvider.toggleFavorite
/// directamente desde las pantallas (mismo patrón que CartGuard).
class FavoritesGuard {
  static void toggleFavorite(BuildContext context, Product product) {
    final auth = context.read<AuthProvider>();

    if (!auth.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión para agregar a favoritos'),
        ),
      );
      return;
    }

    final favoritesProvider = context.read<FavoritesProvider>();
    final wasFavorite = favoritesProvider.isFavorite(product);

    favoritesProvider.toggleFavorite(product);

    // Ajuste optimista del contador de favoritos que se ve en la
    // tarjeta/detalle del producto, sin esperar a recargar el catálogo.
    context.read<ProductProvider>().adjustFavoritesCount(product.id, wasFavorite ? -1 : 1);
  }
}
