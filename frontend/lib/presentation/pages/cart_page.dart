import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/cart_provider.dart';
import '../../data/models/product.dart';
import '../components/cart_/cart_item_card.dart';
import '../components/cart_/cart_summary_panel.dart';
import '../components/cart_/cart_empty_state.dart';

class _CartGroup {
  final Product product;
  int quantity;

  _CartGroup({required this.product, required this.quantity});
}

class CartPage extends StatelessWidget {
  final VoidCallback? onExploreMenu;

  const CartPage({super.key, this.onExploreMenu});

  @override
  Widget build(BuildContext context) {
    const primaryBrown = Color(0xFF9E754B);
    const scaffoldBgColor = Color(0xFFF7F4EF);
    const cardBgColor = Colors.white;

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          final int totalItems = cart.items.length;

          final Map<String, _CartGroup> groupedItems = {};
          for (var product in cart.items) {
            if (groupedItems.containsKey(product.id)) {
              groupedItems[product.id]!.quantity++;
            } else {
              groupedItems[product.id] = _CartGroup(product: product, quantity: 1);
            }
          }

          final itemList = groupedItems.values.toList()
            ..sort((a, b) => a.product.id.compareTo(b.product.id));

          final double totalPrice = cart.items.fold(0.0, (sum, item) => sum + item.price);

          return Column(
            children: [
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
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          Text(
                            '$totalItems ${totalItems == 1 ? "producto" : "productos"}',
                            style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8)),
                          ),
                        ],
                      ),
                    ),
                    if (totalItems > 0)
                      TextButton(
                        onPressed: () => cart.clearCart(),
                        child: const Text(
                          'Vaciar',
                          style: TextStyle(color: Colors.white, decoration: TextDecoration.underline, fontSize: 14),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: totalItems == 0
                    ? CartEmptyState(primaryBrown: primaryBrown, onExploreMenu: onExploreMenu)
                    : Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: itemList.length,
                              itemBuilder: (context, index) {
                                final group = itemList[index];
                                return CartItemCard(
                                  product: group.product,
                                  quantity: group.quantity,
                                  primaryBrown: primaryBrown,
                                  cardBgColor: cardBgColor,
                                  onAdd: () => cart.addToCart(group.product),
                                  onRemoveSingle: () => cart.removeSingleItem(group.product),
                                  onDeleteAll: () {
                                    for (int i = 0; i < group.quantity; i++) {
                                      cart.removeSingleItem(group.product);
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                          CartSummaryPanel(
                            totalPrice: totalPrice,
                            primaryBrown: primaryBrown,
                            onCheckout: () {
                              cart.clearCart();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('¡Pedido realizado con éxito!'),
                                  backgroundColor: primaryBrown,
                                ),
                              );
                            },
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
}