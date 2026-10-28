import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product_customization.dart';
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
    ProductCustomization? customization,
  }) async {
    final auth = context.read<AuthProvider>();

    if (!auth.isLoggedIn) {
      _showLoginRequiredSnackBar(context);
      return;
    }

    // Se toman antes del await: la pantalla que llamó (p. ej. el detalle)
    // suele cerrarse mientras el servidor responde, y el aviso debe
    // mostrarse igual.
    final cart = context.read<CartProvider>();
    final messenger = ScaffoldMessenger.of(context);

    await cart.addToCart(
      product,
      quantity: quantity,
      customization: customization,
    );

    // Si el servidor rechazó el alta (p. ej. el precio cambió) se avisa
    // en vez de anunciar un éxito falso.
    final rejected = cart.lastAddError;
    messenger.showSnackBar(
      SnackBar(
        content: Text(rejected ?? '${product.name} añadido al carrito'),
        backgroundColor: rejected == null ? AppColors.primary : Colors.red.shade700,
        duration: Duration(seconds: rejected == null ? 2 : 4),
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
