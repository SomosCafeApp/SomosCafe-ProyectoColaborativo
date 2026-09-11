import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../models/welcome_data.dart';
import '../providers/cart_provider.dart';
import '../widgets/welcome/category_selector.dart';
import '../widgets/welcome/filtered_menu_section.dart';
import '../widgets/welcome/hero_header.dart';
import '../widgets/welcome/offer_card.dart';
import '../widgets/welcome/popular_products_section.dart';
import '../widgets/welcome/welcome_divider.dart';

class WelcomePage extends StatefulWidget {
  final VoidCallback? onOrderNow;

  const WelcomePage({super.key, this.onOrderNow});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  int _selectedCategoryIndex = 0;

  void _addToCart(BuildContext context, Product product) {
    Provider.of<CartProvider>(context, listen: false).addToCart(product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} añadido al carrito'), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryBrown = theme.colorScheme.primary;
    final selectedCatId = WelcomeData.categories[_selectedCategoryIndex]['id'];
    final filtered = WelcomeData.fullMenuProducts.where((p) => p.categoryId == selectedCatId).toList();

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
                  Text('Categorías', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                  const SizedBox(height: 2),
                  Text('Explora nuestro menú', style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.55))),
                  const SizedBox(height: 16),
                  CategorySelector(
                    categories: WelcomeData.categories,
                    selectedIndex: _selectedCategoryIndex,
                    onCategorySelected: (idx) => setState(() => _selectedCategoryIndex = idx),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            PopularProductsSection(
              products: WelcomeData.popularProducts,
              onOrderNow: widget.onOrderNow,
              onAddToCart: (p) => _addToCart(context, p),
            ),
            const SizedBox(height: 32),
            const WelcomeDivider(),
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
                    side: BorderSide(color: primaryBrown.withOpacity(0.3), width: 1.2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Ver Menú Completo', style: TextStyle(color: primaryBrown, fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, color: primaryBrown, size: 16),
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