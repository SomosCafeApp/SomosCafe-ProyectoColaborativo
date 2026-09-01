import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/cart_provider.dart';
import '../../data/models/product.dart';

class CartPage extends StatelessWidget {
  final VoidCallback? onExploreMenu;

  const CartPage({super.key, this.onExploreMenu});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryBrown = theme.colorScheme.primary;
    final scaffoldBgColor = theme.scaffoldBackgroundColor;
    final cardBgColor = theme.cardColor;
    final textColor = theme.colorScheme.onSurface;
    final subtitleColor = textColor.withAlpha(150);
    final panelBgColor = isDark ? const Color(0xFF2A1F19) : const Color(0xFFEFECE6);
    final totalCardBg = isDark ? Colors.white.withOpacity(0.06) : Colors.white.withOpacity(0.6);
    final quantityPillBg = isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFF5F5F5);

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          final int totalItems = cart.items.length;

          // Agrupamos los productos repetidos
          final Map<String, _CartGroup> groupedItems = {};
          for (var product in cart.items) {
            if (groupedItems.containsKey(product.id)) {
              groupedItems[product.id]!.quantity++;
            } else {
              groupedItems[product.id] = _CartGroup(product: product, quantity: 1);
            }
          }

          // Convertimos a lista ordenada para mantener posiciones fijas
          final itemList = groupedItems.values.toList()
            ..sort((a, b) => a.product.id.compareTo(b.product.id));

          final double totalPrice = cart.items.fold(0.0, (sum, item) => sum + item.price);

          return Column(
            children: [
              // Header Superior
              Container(
                color: primaryBrown,
                padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
                width: double.infinity,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.inventory_2_outlined, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Mi Carrito',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '$totalItems ${totalItems == 1 ? "producto" : "productos"}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (totalItems > 0)
                      TextButton(
                        onPressed: () => cart.clearCart(),
                        child: const Text(
                          'Vaciar',
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                            fontSize: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Contenido Principal
              Expanded(
                child: totalItems == 0
                    ? _buildEmptyCart(primaryBrown, textColor, subtitleColor)
                    : Column(
                        children: [
                          // Lista de Productos
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: itemList.length,
                              itemBuilder: (context, index) {
                                final group = itemList[index];
                                final product = group.product;
                                final quantity = group.quantity;

                                return Container(
                                  key: ValueKey(product.id),
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: cardBgColor,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.03),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // Imagen del producto
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.network(
                                          product.imageUrl,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              width: 80,
                                              height: 80,
                                              color: primaryBrown.withOpacity(0.1),
                                              child: Icon(Icons.coffee, color: primaryBrown),
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 12),

                                      // Información del Producto
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    product.name,
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                      color: textColor,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                // Botón Eliminar: Remueve TODAS las unidades del producto
                                                IconButton(
                                                  constraints: const BoxConstraints(),
                                                  padding: EdgeInsets.zero,
                                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                                  onPressed: () {
                                                    for (int i = 0; i < quantity; i++) {
                                                      cart.removeSingleItem(product);
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                            Text(
                                              product.description,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: subtitleColor,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  '\$${(product.price * quantity).toStringAsFixed(0)} COP',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    color: textColor,
                                                  ),
                                                ),

                                                // Controles de Cantidad
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: quantityPillBg,
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      // Botón de Restar (Inhabilitado si cantidad es 1)
                                                      InkWell(
                                                        onTap: quantity > 1
                                                            ? () => cart.removeSingleItem(product)
                                                            : null,
                                                        borderRadius: BorderRadius.circular(20),
                                                        child: Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                          child: Text(
                                                            '-',
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              color: quantity > 1
                                                                  ? textColor
                                                                  : subtitleColor,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 6),
                                                        child: Text(
                                                          '$quantity',
                                                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
                                                        ),
                                                      ),
                                                      // Botón de Sumar
                                                      InkWell(
                                                        onTap: () => cart.addToCart(product),
                                                        borderRadius: BorderRadius.circular(20),
                                                        child: Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                          child: Text(
                                                            '+',
                                                            style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),

                          // Panel Inferior
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: panelBgColor,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: totalCardBg,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Total',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                      Text(
                                        '\$${totalPrice.toStringAsFixed(0)} COP',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      cart.clearCart();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: const Text('¡Pedido realizado con éxito!'),
                                          backgroundColor: primaryBrown,
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryBrown,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(26),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Realizar Pedido',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyCart(Color primaryBrown, Color textColor, Color subtitleColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryBrown.withOpacity(0.15),
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 40,
              color: primaryBrown,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Tu carrito está vacío',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Añade productos para continuar',
            style: TextStyle(
              fontSize: 14,
              color: subtitleColor,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onExploreMenu,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBrown,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Explorar Menú',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartGroup {
  final Product product;
  int quantity;

  _CartGroup({required this.product, required this.quantity});
}