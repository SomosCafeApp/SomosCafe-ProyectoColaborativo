import 'package:flutter/material.dart';
import '../../data/models/product.dart';
import '../../data/providers/product_provider.dart';

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
    _filteredProducts = []; // Inicia vacío para mostrar el estado inicial
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
    final headerBgColor = primaryBrown;
    final scaffoldBgColor = theme.scaffoldBackgroundColor;
    final cardBgColor = theme.cardColor;
    final textColor = theme.colorScheme.onSurface;
    final subtitleColor = textColor.withAlpha(150);
    final searchFieldBg = isDark ? const Color(0xFF3D2E26) : Colors.white;
    final searchHintColor = isDark ? Colors.white54 : Colors.grey.shade500;

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      body: Column(
        children: [
          // Header
          Container(
            color: headerBgColor,
            padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Buscar',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchController,
                  onChanged: _filterProducts,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Buscar café, postre...',
                    hintStyle: TextStyle(color: searchHintColor, fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: searchHintColor),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: searchHintColor),
                            onPressed: () {
                              _searchController.clear();
                              _filterProducts('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: searchFieldBg,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Contenido de la búsqueda
          Expanded(
            child: _searchController.text.isEmpty
                ? _buildEmptyState(primaryBrown, textColor, subtitleColor)
                : _filteredProducts.isEmpty
                    ? _buildNoResultsState(textColor, subtitleColor)
                    : _buildResultsList(primaryBrown, cardBgColor, textColor, subtitleColor),
          ),
        ],
      ),
    );
  }

  // Vista cuando el buscador está vacío
  Widget _buildEmptyState(Color primaryBrown, Color textColor, Color subtitleColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryBrown.withOpacity(0.15),
            ),
            child: Icon(
              Icons.search,
              size: 40,
              color: primaryBrown,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Busca tu bebida favorita',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Encuentra cafés, bebidas frías y postres',
            style: TextStyle(
              fontSize: 14,
              color: subtitleColor,
            ),
          ),
        ],
      ),
    );
  }

  // Vista cuando no hay coincidencias
  Widget _buildNoResultsState(Color textColor, Color subtitleColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 60, color: subtitleColor),
          const SizedBox(height: 16),
          Text(
            'No se encontraron resultados',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 4),
          Text(
            'Intenta buscando con otra palabra',
            style: TextStyle(color: subtitleColor),
          ),
        ],
      ),
    );
  }

  // Lista de resultados
  Widget _buildResultsList(Color primaryBrown, Color cardBgColor, Color textColor, Color subtitleColor) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return Card(
          color: cardBgColor,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 1,
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: primaryBrown.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.coffee, color: primaryBrown),
            ),
            title: Text(
              product.name,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor),
            ),
            subtitle: Text(
              product.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: subtitleColor),
            ),
            trailing: Text(
              '\$${product.price.toStringAsFixed(0)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: primaryBrown,
                fontSize: 14,
              ),
            ),
          ),
        );
      },
    );
  }
}