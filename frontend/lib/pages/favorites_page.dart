import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/utils/cart_guard.dart';
import '../widgets/product_card.dart';
import '../widgets/profile/profile_sub_page_header.dart';
import '../providers/favorites_provider.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = theme.scaffoldBackgroundColor;

    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;

    final subtitleColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    final emptyIconBackground = isDark
        ? AppColors.darkSurfaceSubtle
        : AppColors.lightSurfaceSubtle;

    final emptyIconColor = AppColors.primary;

    final favoritesProvider = context.watch<FavoritesProvider>();
    final favorites = favoritesProvider.favorites;


    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          ProfileSubPageHeader(
            title: 'Favoritos',
            subtitle: 'Tus productos favoritos',
          ),

          Expanded(
            child: favorites.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              color: emptyIconBackground,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.favorite_border_rounded,
                                size: 58,
                                color: emptyIconColor,
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          Text(
                            'No tienes favoritos',
                            textAlign: TextAlign.center,
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
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.shopping_cart_outlined,
                              size: 20,
                            ),
                            label: const Text(
                              'Explorar Menú',
                              style: TextStyle(
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
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.68,
                    ),
                    itemBuilder: (context, index) {
                      final product = favorites[index];

                      return ProductCard(
                        product: product,
                        onAddToCart: () => CartGuard.addToCart(context, product),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}