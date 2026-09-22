import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
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

  // Diseño y textos fijos, tal cual el mockup. `keywords` se usa
  // para encontrar, entre los productos reales del backend, cuáles
  // pertenecen a cada tarjeta (comparando contra el nombre de la
  // categoría que cada producto trae poblada).
  static const List<Map<String, dynamic>> _categories = [
    {
      'id': 'hot_coffee',
      'label': 'Cafés\nCalientes',
      'icon': Icons.coffee_rounded,
      'bgColor': Color(0xFFFEF3D6),
      'iconBgColor': Color(0xFFF7E2AD),
      'iconColor': Color(0xFF8C5C2B),
      'keywords': ['caliente', 'hot', 'café', 'cafe', 'coffee'],
    },
    {
      'id': 'cold_drinks',
      'label': 'Bebidas\nFrías',
      'icon': Icons.ac_unit_rounded,
      'bgColor': Color(0xFFE1F5FE),
      'iconBgColor': Color(0xFFB3E5FC),
      'iconColor': Color(0xFF0288D1),
      'keywords': ['fría', 'fria', 'cold', 'helad', 'frappe', 'frappé'],
    },
    {
      'id': 'desserts',
      'label': 'Postres',
      'icon': Icons.cake_rounded,
      'bgColor': Color(0xFFFCE4EC),
      'iconBgColor': Color(0xFFF8BBD0),
      'iconColor': Color(0xFFC2185B),
      'keywords': ['postre', 'dessert', 'torta', 'pastel', 'cheesecake'],
    },
  ];

  List<Product> _productsForCategory(List<Product> allProducts, int index) {
    final keywords = (_categories[index]['keywords'] as List).cast<String>();
    return allProducts.where((p) {
      final name = (p.categoryName ?? '').toLowerCase();
      if (name.isEmpty) return false;
      return keywords.any((k) => name.contains(k));
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProductProvider>();
      if (provider.products.isEmpty) {
        provider.fetchProducts();
      }
    });
  }

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
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final productProvider = context.watch<ProductProvider>();
    final allProducts = productProvider.products;

    final filtered = _productsForCategory(allProducts, _selectedCategoryIndex).take(4).toList();

    // "Populares": los mejor calificados; si nadie tiene rating aún,
    // mostramos los primeros para no dejar la sección vacía.
    final popular = ([...allProducts]..sort((a, b) => b.rating.compareTo(a.rating)))
        .take(4)
        .toList();

    if (productProvider.isLoading && allProducts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (productProvider.errorMessage != null && allProducts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_rounded, size: 42, color: primaryBrown.withOpacity(0.6)),
              const SizedBox(height: 12),
              Text(
                productProvider.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => productProvider.fetchProducts(),
                style: ElevatedButton.styleFrom(backgroundColor: primaryBrown),
                child: const Text('Reintentar', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: () => productProvider.fetchProducts(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
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
                      style: TextStyle(fontSize: 13, color: subtitleColor),
                    ),
                    const SizedBox(height: 16),
                    CategorySelector(
                      categories: _categories,
                      selectedIndex: _selectedCategoryIndex,
                      onCategorySelected: (idx) =>
                          setState(() => _selectedCategoryIndex = idx),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              if (popular.isNotEmpty) ...[
                PopularProductsSection(
                  products: popular,
                  onOrderNow: widget.onOrderNow,
                  onAddToCart: (p) => _addToCart(context, p),
                ),
                const SizedBox(height: 32),
                const HomeDivider(),
                const SizedBox(height: 28),
              ],
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
                      backgroundColor: isDark ? AppColors.darkBackground : Colors.transparent,
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
      ),
    );
  }
}
