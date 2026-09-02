import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/product_card.dart';
import '../state/cart_provider.dart';
import '../state/favorites_provider.dart';
import '../state/theme_provider.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    // Paleta exacta de la imagen
    final headerBgColor = isDark ? const Color(0xFFA2784F) : const Color(0xFF9E7247);
    final scaffoldBgColor = isDark ? const Color(0xFF1E1410) : const Color(0xFFFAF7F2);
    final emptyCircleBg = isDark ? const Color(0xFF2D211B) : const Color(0xFFEBE0D3);
    
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white70 : Colors.black54;

    final favoritesProvider = context.watch<FavoritesProvider>();
    final favorites = favoritesProvider.favorites;
    final cartProvider = context.read<CartProvider>();

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      body: Column(
        children: [
          // --- HEADER SUPERIOR ---
          Container(
            padding: const EdgeInsets.only(top: 50, bottom: 20, left: 16, right: 16),
            width: double.infinity,
            color: headerBgColor,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mis Favoritos',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      favorites.isEmpty
                          ? '0 productos guardados'
                          : '${favorites.length} producto${favorites.length == 1 ? '' : 's'} guardado${favorites.length == 1 ? '' : 's'}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- CONTENIDO ---
          Expanded(
            child: favorites.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              color: emptyCircleBg,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.favorite_border_rounded,
                                size: 58,
                                color: Color(0xFFA2784F),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),

                          Text(
                            'No tienes favoritos',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 12),

                          Text(
                            'Explora nuestro menú y marca tus productos favoritos para encontrarlos fácilmente aquí',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: subtitleColor,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 28),

                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFA2784F),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 2,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 20),
                            label: const Text(
                              'Explorar Menú',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: favorites.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.68,
                    ),
                    itemBuilder: (context, index) {
                      final product = favorites[index];
                      return ProductCard(
                        product: product,
                        onAddToCart: () {
                          cartProvider.addToCart(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product.name} añadido al carrito'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
} 