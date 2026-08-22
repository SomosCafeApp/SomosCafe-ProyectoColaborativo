import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/product.dart';
import '../components/product_card.dart';
import '../state/cart_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedCategoryIndex = 0;

  final List<Map<String, dynamic>> _categories = [
    {'label': 'Todo', 'icon': Icons.auto_awesome},
    {'label': 'Calientes', 'icon': Icons.coffee_rounded},
    {'label': 'Frías', 'icon': Icons.ac_unit_rounded},
    {'label': 'Postres', 'icon': Icons.cake_rounded},
  ];

  final List<Product> _originalProducts = [
    Product(
      id: '1',
      name: 'Espresso Tradicional',
      description: 'Intenso y aromático, la esencia pura del café',
      price: 4500,
      imageUrl: '',
    ),
    Product(
      id: '2',
      name: 'Cappuccino de la Casa',
      description: 'Espresso coronado con espuma de leche sedosa',
      price: 7000,
      imageUrl: '',
    ),
    Product(
      id: '3',
      name: 'Latte Moca',
      description: 'Mezcla perfecta de café espresso, leche y chocolate',
      price: 8500,
      imageUrl: '',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    const primaryBrown = Color(0xFF8C6239);
    const darkHeaderBg = Color(0xFF9E7247);
    const scaffoldBgColor = Color(0xFFFAF7F2);

    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // --- HEADER CON CATEGORÍAS ---
            Container(
              padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
              decoration: const BoxDecoration(
                color: darkHeaderBg,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.coffee_rounded, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
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
                              color: Colors.white70,
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
                              color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _categories[index]['icon'],
                                  size: 16,
                                  color: isSelected ? primaryBrown : Colors.white,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _categories[index]['label'],
                                  style: TextStyle(
                                    color: isSelected ? primaryBrown : Colors.white,
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
                  const Icon(Icons.auto_awesome, size: 16, color: primaryBrown),
                  const SizedBox(width: 6),
                  Text(
                    '${_originalProducts.length} productos disponibles',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // --- GRID DE PRODUCTOS ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _originalProducts.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.68,
                  ),
                  itemBuilder: (context, index) {
                    final product = _originalProducts[index];
                    return ProductCard(
                      product: product,
                      onAddToCart: () {
                        cartProvider.addToCart(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.name} añadido al carrito'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}