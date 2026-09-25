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
      _showLoginRequiredDialog(context);
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

  static void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Inicia sesión'),
        content: const Text(
          'Debes iniciar sesión para agregar productos al carrito.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Entendido', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
