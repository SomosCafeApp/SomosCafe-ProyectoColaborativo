import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../constants/app_colors.dart';

/// Centraliza la regla "hay que estar logueado para agregar al
/// carrito". Se usa en vez de llamar a CartProvider.addToCart
/// directamente desde las pantallas.
class CartGuard {
  static Future<void> addToCart(
    BuildContext context,
    Product product, {
    int quantity = 1,
  }) async {
    final auth = context.read<AuthProvider>();

    if (!auth.isLoggedIn) {
      _showLoginRequiredSnackBar(context);
      return;
    }

    await context.read<CartProvider>().addToCart(product, quantity: quantity);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} añadido al carrito'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static void _showLoginRequiredSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Debes iniciar sesión para agregar productos al carrito'),
      ),
    );
  }
}
