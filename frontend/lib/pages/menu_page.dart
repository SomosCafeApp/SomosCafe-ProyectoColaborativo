import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../models/product_model.dart';
import '../widgets/product_card.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  int _selectedCategoryIndex = 0;

  final List<Map<String, dynamic>> _categories = const [
    {'label': 'Todo', 'icon': Icons.auto_awesome},
    {'label': 'Calientes', 'icon': Icons.coffee_rounded},
    {'label': 'Frías', 'icon': Icons.ac_unit_rounded},
    {'label': 'Postres', 'icon': Icons.cake_rounded},
  ];

  @override
  void initState() {
    super.initState();
    // Se dispara después del primer frame para poder usar `context.read`
    // de forma segura dentro de initState.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
    });
  }

  List<Product> _applyCategoryFilter(List<Product> products) {
    final label = _categories[_selectedCategoryIndex]['label'] as String;
    if (label == 'Todo') return products;
    return products
        .where((p) => (p.categoryName ?? '').toLowerCase() == label.toLowerCase())
        .toList();
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
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final isSelected = _selectedCategoryIndex == index;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategoryIndex = index;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _categories[index]['icon'],
                                  size: 16,
                                  color: isSelected ? AppColors.primary : Colors.white,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _categories[index]['label'],
                                  style: TextStyle(
                                    color: isSelected ? AppColors.primary : Colors.white,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
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
      return const Center(child: CircularProgressIndicator());
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
            return ProductCard(
              product: product,
              onAddToCart: () {
                cartProvider.addToCart(product);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${product.name} añadido al carrito'),
                    backgroundColor: AppColors.primary,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
