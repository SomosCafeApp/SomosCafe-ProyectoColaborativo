import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../models/product_model.dart';
import '../core/utils/cart_guard.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/search/search_header.dart';
import '../widgets/search/search_state_message.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    // Si el menú aún no cargó los productos (p. ej. se entró directo
    // a Buscar), los pedimos aquí también. ProductProvider evita
    // llamadas duplicadas innecesarias gracias al estado compartido.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProductProvider>();
      if (provider.products.isEmpty) {
        provider.fetchProducts();
      }
    });
  }

  void _filterProducts(String query) {
    final allProducts = context.read<ProductProvider>().products;
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = [];
      } else {
        _filteredProducts = allProducts.where((product) {
          final nameLower = product.name.toLowerCase();
          final descLower = product.description.toLowerCase();
          final searchLower = query.toLowerCase();
          return nameLower.contains(searchLower) || descLower.contains(searchLower);
        }).toList();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _filterProducts('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryBrown = theme.colorScheme.primary;
    final subtitleColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          SearchHeader(
            controller: _searchController,
            onChanged: _filterProducts,
            onClear: _clearSearch,
          ),
          Expanded(
            child: _buildBodyContent(context, primaryBrown, subtitleColor, cartProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyContent(
    BuildContext context,
    Color primaryBrown,
    Color subtitleColor,
    CartProvider cartProvider,
  ) {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      return const SearchStateMessage(
        icon: Icons.search,
        title: 'Busca tu bebida favorita',
        subtitle: 'Encuentra cafés, bebidas frías y postres',
      );
    }

    if (_filteredProducts.isEmpty) {
      return const SearchStateMessage(
        icon: Icons.search_off,
        title: 'No se encontraron resultados',
        subtitle: 'Intenta buscando con otra palabra',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Contador de resultados exacto como Figma
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Text(
            '${_filteredProducts.length} resultados para "$query"',
            style: TextStyle(
              fontSize: 13,
              color: subtitleColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.builder(
              padding: const EdgeInsets.only(bottom: 20),
              physics: const BouncingScrollPhysics(),
              itemCount: _filteredProducts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.68,
              ),
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                return ProductCard(
                  product: product,
                  onAddToCart: () => CartGuard.addToCart(context, product),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}