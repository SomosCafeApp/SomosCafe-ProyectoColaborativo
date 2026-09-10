import 'package:flutter/material.dart';
import '../../data/models/product.dart';
import '../../data/providers/product_provider.dart';
import '../components/search/search_header.dart';
import '../components/search/search_result_item.dart';
import '../components/search/search_state_message.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _allProducts = ProductData.getProducts();
    _filteredProducts = [];
  }

  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = [];
      } else {
        _filteredProducts = _allProducts.where((product) {
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
    final primaryBrown = theme.colorScheme.primary;

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
            child: _buildBodyContent(primaryBrown),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyContent(Color primaryBrown) {
    if (_searchController.text.isEmpty) {
      return SearchStateMessage(
        icon: Icons.search,
        title: 'Busca tu bebida favorita',
        subtitle: 'Encuentra cafés, bebidas frías y postres',
        iconColor: primaryBrown,
        iconBgColor: primaryBrown.withAlpha(38),
      );
    }

    if (_filteredProducts.isEmpty) {
      return const SearchStateMessage(
        icon: Icons.search_off,
        title: 'No se encontraron resultados',
        subtitle: 'Intenta buscando con otra palabra',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        return SearchResultItem(product: _filteredProducts[index]);
      },
    );
  }
}