import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../models/product_model.dart';
import '../models/product_data.dart';
import '../providers/cart_provider.dart';
import '../widgets/home/category_selector.dart';
import '../widgets/home/filtered_menu_section.dart';
import '../widgets/home/hero_header.dart';
import '../widgets/home/offer_card.dart';
import '../widgets/home/popular_products_section.dart';
import '../widgets/home/home_divider.dart';

class HomePage extends StatefulWidget {
  final VoidCallback? onOrderNow;

  const HomePage({super.key, this.onOrderNow});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedCategoryIndex = 0;

  void _addToCart(BuildContext context, Product product) {
    Provider.of<CartProvider>(context, listen: false).addToCart(product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} añadido al carrito'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryBrown = theme.colorScheme.primary;

    final selectedCatId = ProductData.categories[_selectedCategoryIndex]['id'];
    final filtered = ProductData.fullMenuProducts
        .where((p) => p.categoryId == selectedCatId)
        .toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HeroHeader(),
            OfferCard(onOrderNow: widget.onOrderNow),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Categorías',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Explora nuestro menú',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CategorySelector(
                    categories: ProductData.categories,
                    selectedIndex: _selectedCategoryIndex,
                    onCategorySelected: (idx) =>
                        setState(() => _selectedCategoryIndex = idx),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            PopularProductsSection(
              products: ProductData.popularProducts,
              onOrderNow: widget.onOrderNow,
              onAddToCart: (p) => _addToCart(context, p),
            ),
            const SizedBox(height: 32),
            const HomeDivider(),
            const SizedBox(height: 28),
            FilteredMenuSection(
              products: filtered,
              onAddToCart: (p) => _addToCart(context, p),
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: widget.onOrderNow,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: isDark
                          ? AppColors.darkSurfaceSubtle
                          : primaryBrown.withOpacity(0.3),
                      width: 1.2,
                    ),
                    backgroundColor: isDark
                        ? AppColors.darkBackground
                        : Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Ver Menú Completo',
                        style: TextStyle(
                          color: primaryBrown,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: primaryBrown,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}