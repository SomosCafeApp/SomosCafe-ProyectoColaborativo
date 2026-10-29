import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/cart_provider.dart';
import 'order_confirmation_page.dart';
import '../widgets/cart/cart_item_card.dart';
import '../widgets/cart/cart_summary_panel.dart';
import '../widgets/cart/cart_empty_state.dart';

class CartPage extends StatelessWidget {
  final VoidCallback? onExploreMenu;

  const CartPage({super.key, this.onExploreMenu});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryBrown = AppColors.primary;
    final scaffoldBgColor = theme.scaffoldBackgroundColor;
    final cardBgColor = theme.cardTheme.color ??
        (isDark ? AppColors.darkSurface : AppColors.lightSurface);

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      body: Consumer(
        builder: (BuildContext context, CartProvider cart, Widget? child) {
          final lines = cart.lines;
          final int totalItems = cart.itemCount;
          final double totalPrice = cart.total;

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
                        color: Colors.white.withValues(alpha: 0.2),
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
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.8),
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
                              itemCount: lines.length,
                              itemBuilder: (context, index) {
                                final line = lines[index];
                                return CartItemCard(
                                  line: line,
                                  primaryBrown: primaryBrown,
                                  cardBgColor: cardBgColor,
                                  onAdd: () => cart.incrementLine(line),
                                  onRemoveSingle: () => cart.removeSingleItem(line),
                                  onDeleteAll: () => cart.removeLine(line),
                                );
                              },
                            ),
                          ),
                          CartSummaryPanel(
                            totalPrice: totalPrice,
                            primaryBrown: primaryBrown,
                            // No se crea la orden aquí: primero se abre la
                            // confirmación (entrega, receptor, dirección, pago).
                            onCheckout: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const OrderConfirmationPage()),
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
}