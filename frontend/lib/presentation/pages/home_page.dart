import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/product_provider.dart';
import '../components/product_card.dart';
import '../state/cart_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedCategory = 0;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Todo', 'icon': Icons.auto_awesome},
    {'name': 'Calientes', 'icon': Icons.coffee_rounded},
    {'name': 'Frías', 'icon': Icons.ac_unit_rounded},
    {'name': 'Postres', 'icon': Icons.cake_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    final products = ProductData.getProducts();

    const headerBgColor = Color(0xFF9E754B);
    const primaryBrown = Color(0xFFA2784F);
    const scaffoldBgColor = Color(0xFFFAF7F2);

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      body: Column(
        children: [
          // --- HEADER CON TONO CAFÉ Y FILTROS POR CATEGORÍA ---
          Container(
            color: headerBgColor,
            padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título y Subtítulo
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.coffee_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
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
                          'Más de 12 productos artesanales',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.87),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Lista de Filtros Categorías (Horizontal)
                SizedBox(
                  height: 42,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedCategory == index;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = index;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _categories[index]['icon'],
                                size: 16,
                                color: isSelected ? primaryBrown : Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _categories[index]['name'],
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? primaryBrown : Colors.white,
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

          // --- LISTA DE PRODUCTOS ---
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              children: [
                // Contador de productos
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, size: 14, color: primaryBrown),
                    const SizedBox(width: 6),
                    Text(
                      '${products.length} productos disponibles',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Render de productos utilizando ProductCard y CartProvider
                ...products.map(
                  (product) => ProductCard(
                    product: product,
                    onAddToCart: () {
                      context.read<CartProvider>().addToCart(product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product.name} agregado al carrito'),
                          backgroundColor: primaryBrown,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}