import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/utils/cart_guard.dart';
import '../core/utils/popular_products.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';
import '../providers/promo_of_the_day_provider.dart';
import '../widgets/home/category_selector.dart';
import '../widgets/home/filtered_menu_section.dart';
import '../widgets/home/hero_header.dart';
import '../widgets/home/offer_card.dart';
import '../widgets/home/popular_products_section.dart';
import '../widgets/home/home_divider.dart';

import '../animations/animations.dart';
class HomePage extends StatefulWidget {
  final VoidCallback? onOrderNow;

  /// Se llama con el id de la categoría tocada para abrir el Menú ya
  /// filtrado. Si no se entrega, se abre el Menú sin filtro.
  final ValueChanged<String>? onCategorySelected;

  const HomePage({super.key, this.onOrderNow, this.onCategorySelected});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Diseño y textos fijos, tal cual el mockup. El 'id' coincide con el de
  // las categorías del Menú, que es quien filtra los productos.
  static const List<Map<String, dynamic>> _categories = [
    {
      'id': 'hot_coffee',
      'label': 'Cafés\nCalientes',
      'icon': Icons.coffee_rounded,
      'bgColor': Color(0xFFFEF3D6),
      'iconBgColor': Color(0xFFF7E2AD),
      'iconColor': Color(0xFF8C5C2B),
    },
    {
      'id': 'cold_drinks',
      'label': 'Bebidas\nFrías',
      'icon': Icons.ac_unit_rounded,
      'bgColor': Color(0xFFE1F5FE),
      'iconBgColor': Color(0xFFB3E5FC),
      'iconColor': Color(0xFF0288D1),
    },
    {
      'id': 'desserts',
      'label': 'Postres',
      'icon': Icons.cake_rounded,
      'bgColor': Color(0xFFFCE4EC),
      'iconBgColor': Color(0xFFF8BBD0),
      'iconColor': Color(0xFFC2185B),
    },
  ];

  void _openCategory(String categoryId) {
    final callback = widget.onCategorySelected;
    if (callback != null) {
      callback(categoryId);
    } else {
      widget.onOrderNow?.call();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProductProvider>();
      if (provider.products.isEmpty) {
        provider.fetchProducts();
      }
      // La promo del día se pide siempre al entrar: el admin pudo
      // cambiarla desde la última vez.
      context.read<PromoOfTheDayProvider>().fetchPromo();
    });
  }

  /// Recarga productos (precios con descuento) y promo del día.
  Future<void> _refresh() => Future.wait([
        context.read<ProductProvider>().fetchProducts(),
        context.read<PromoOfTheDayProvider>().fetchPromo(),
      ]);

  void _addToCart(BuildContext context, Product product) {
    CartGuard.addToCart(context, product);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryBrown = theme.colorScheme.primary;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final productProvider = context.watch<ProductProvider>();
    final allProducts = productProvider.products;
    final promo = context.watch<PromoOfTheDayProvider>().promo;

    // "Populares": los 4 productos mejor calificados (ver topRatedProducts).
    final popular = topRatedProducts(allProducts);

    // Vista previa del menú: productos que no están ya en "Populares".
    final popularIds = popular.map((p) => p.id).toSet();
    final menuPreview = allProducts.where((p) => !popularIds.contains(p.id)).take(4).toList();

    if (productProvider.isLoading && allProducts.isEmpty) {
      return const HomeSkeleton();
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
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeroHeader(productCount: allProducts.length),
              // Sin promo del día vigente no se dibuja la tarjeta.
              if (promo != null)
                FadeSlideIn(
                  delay: const Duration(milliseconds: 120),
                  child: OfferCard(promo: promo, onOrderNow: widget.onOrderNow),
                )
              else
                const SizedBox(height: 20),
              FadeSlideIn(
                delay: const Duration(milliseconds: 200),
                child: Padding(
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
                      onCategorySelected: _openCategory,
                    ),
                  ],
                ),
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
              if (menuPreview.isNotEmpty) ...[
                FilteredMenuSection(
                  products: menuPreview,
                  onAddToCart: (p) => _addToCart(context, p),
                ),
                const SizedBox(height: 28),
              ],
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
