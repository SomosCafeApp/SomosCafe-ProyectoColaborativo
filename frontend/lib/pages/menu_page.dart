import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/cart_guard.dart';
import '../core/utils/menu_category_request.dart';
import '../models/product_model.dart';
import '../widgets/menu/menu_category_chips.dart';
import '../widgets/product_card.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';

import '../animations/animations.dart';
class MenuPage extends StatefulWidget {
  /// Si llega una petición nueva (p. ej. desde las categorías del Home),
  /// el Menú selecciona esa categoría.
  final MenuCategoryRequest? categoryRequest;

  const MenuPage({super.key, this.categoryRequest});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  int _selectedCategoryIndex = 0;
  final ScrollController _scrollController = ScrollController();

  // Los 'id' coinciden con los de las tarjetas de categoría del Home
  // (así el Home puede abrir el Menú ya filtrado). Las palabras clave
  // filtran contra el nombre real de categoría que trae cada producto
  // desde el backend.
  final List<Map<String, dynamic>> _categories = const [
    {'id': 'all', 'label': 'Todo', 'icon': Icons.auto_awesome, 'keywords': <String>[]},
    {
      'id': 'hot_coffee',
      'label': 'Calientes',
      'icon': Icons.coffee_rounded,
      'keywords': ['caliente', 'hot', 'café', 'cafe', 'coffee'],
    },
    {
      'id': 'cold_drinks',
      'label': 'Frías',
      'icon': Icons.ac_unit_rounded,
      'keywords': ['fría', 'fria', 'cold', 'helad', 'frappe', 'frappé'],
    },
    {
      'id': 'desserts',
      'label': 'Postres',
      'icon': Icons.cake_rounded,
      'keywords': ['postre', 'dessert', 'torta', 'pastel', 'cheesecake'],
    },
  ];

  @override
  void initState() {
    super.initState();
    final request = widget.categoryRequest;
    if (request != null) {
      _selectedCategoryIndex = _indexForCategory(request.categoryId);
    }
    // Se dispara después del primer frame para poder usar `context.read`
    // de forma segura dentro de initState.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
    });
  }

  @override
  void didUpdateWidget(MenuPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final request = widget.categoryRequest;
    if (request != null && request.requestId != oldWidget.categoryRequest?.requestId) {
      setState(() => _selectedCategoryIndex = _indexForCategory(request.categoryId));
      if (_scrollController.hasClients) _scrollController.jumpTo(0);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  int _indexForCategory(String id) {
    final index = _categories.indexWhere((c) => c['id'] == id);
    return index < 0 ? 0 : index;
  }

  List<Product> _applyCategoryFilter(List<Product> products) {
    final keywords = (_categories[_selectedCategoryIndex]['keywords'] as List).cast<String>();
    if (keywords.isEmpty) return products; // "Todo"
    return products.where((p) {
      final name = (p.categoryName ?? '').toLowerCase();
      if (name.isEmpty) return false;
      return keywords.any((k) => name.contains(k));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // El header mantiene el tono café de marca en ambos modos según Figma
    final headerBgColor = AppColors.primary;
    final scaffoldBgColor = theme.scaffoldBackgroundColor;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final productProvider = context.watch<ProductProvider>();
    final products = _applyCategoryFilter(productProvider.products);

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // --- HEADER CON CATEGORÍAS ---
            Container(
              padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
              decoration: BoxDecoration(
                color: headerBgColor,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.coffee_rounded, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Nuestro Menú',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Directo desde nuestra cocina',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Filtro Horizontal de Categorías
                  MenuCategoryChips(
                    categories: _categories,
                    selectedIndex: _selectedCategoryIndex,
                    onSelected: (index) => setState(() => _selectedCategoryIndex = index),
                  ),
                ],
              ),
            ),

            // --- CONTADOR DE PRODUCTOS ---
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 16,
                    color: isDark ? AppColors.accentYellow : AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${products.length} productos disponibles',
                    style: TextStyle(
                      fontSize: 13,
                      color: subtitleColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // --- CONTENIDO: LOADING / ERROR / GRID ---
            Expanded(
              child: _buildContent(context, productProvider, products, cartProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ProductProvider productProvider,
    List<Product> products,
    CartProvider cartProvider,
  ) {
    if (productProvider.isLoading && productProvider.products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Shimmer(child: ProductGridSkeleton(count: 6)),
      );
    }

    if (productProvider.errorMessage != null && productProvider.products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_rounded, size: 42, color: AppColors.primary.withOpacity(0.6)),
              const SizedBox(height: 12),
              Text(
                productProvider.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => productProvider.fetchProducts(),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: const Text('Reintentar', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    if (products.isEmpty) {
      return const Center(child: Text('No hay productos en esta categoría'));
    }

    return RefreshIndicator(
      onRefresh: () => productProvider.fetchProducts(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GridView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.only(bottom: 20),
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          itemCount: products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.68,
          ),
          itemBuilder: (context, index) {
            final product = products[index];
            return FadeSlideIn.staggered(
              index: index,
              child: ProductCard(
                product: product,
                onAddToCart: () => CartGuard.addToCart(context, product),
              ),
            );
          },
        ),
      ),
    );
  }
}
