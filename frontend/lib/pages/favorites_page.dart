import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/utils/cart_guard.dart';
import '../providers/favorites_provider.dart';
import '../widgets/favorites/empty_favorites_view.dart';
import '../widgets/product_card.dart';
import '../widgets/profile/profile_sub_page_header.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final favorites = context.watch<FavoritesProvider>().favorites;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          const ProfileSubPageHeader(
            title: 'Favoritos',
            subtitle: 'Tus productos favoritos',
          ),
          Expanded(
            child: favorites.isEmpty
                ? EmptyFavoritesView(
                    onExploreMenu: () => Navigator.of(context).maybePop(),
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
                        onAddToCart: () =>
                            CartGuard.addToCart(context, product),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}