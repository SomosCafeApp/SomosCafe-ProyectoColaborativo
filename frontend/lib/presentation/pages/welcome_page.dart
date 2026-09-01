import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/product.dart';
import '../components/product_card.dart';
import '../state/cart_provider.dart';

class WelcomePage extends StatefulWidget {
  final VoidCallback? onOrderNow;

  const WelcomePage({super.key, this.onOrderNow});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  int _selectedCategoryIndex = 0;

  final List<Map<String, dynamic>> _categories = [
    {
      'id': 'hot_coffee',
      'label': 'Cafés\nCalientes',
      'icon': Icons.coffee_rounded,
      'bgColor': const Color(0xFFFEF3D6),
      'iconBgColor': const Color(0xFFF7E2AD),
      'iconColor': const Color(0xFF8C5C2B),
    },
    {
      'id': 'cold_drinks',
      'label': 'Bebidas\nFrías',
      'icon': Icons.ac_unit_rounded,
      'bgColor': const Color(0xFFE1F5FE),
      'iconBgColor': const Color(0xFFB3E5FC),
      'iconColor': const Color(0xFF0288D1),
    },
    {
      'id': 'desserts',
      'label': 'Postres',
      'icon': Icons.cake_rounded,
      'bgColor': const Color(0xFFFCE4EC),
      'iconBgColor': const Color(0xFFF8BBD0),
      'iconColor': const Color(0xFFC2185B),
    },
  ];

  final List<Product> _popularProducts = [
    Product(
      id: '1',
      name: 'Espresso',
      description: 'Intenso y aromático, la esencia pura del café',
      price: 8000,
      imageUrl: '',
    ),
    Product(
      id: '2',
      name: 'Cappuccino',
      description: 'Espresso coronado con espuma de leche sedosa',
      price: 12000,
      imageUrl: '',
    ),
  ];

  final List<Product> _fullMenuProducts = [
    Product(
      id: '3',
      name: 'Espresso Doble',
      description: 'Doble carga de intenso café recién extraído',
      price: 9500,
      imageUrl: '',
      categoryId: 'hot_coffee',
    ),
    Product(
      id: '4',
      name: 'Cappuccino',
      description: 'Espresso coronado con espuma de leche sedosa',
      price: 12000,
      imageUrl: '',
      categoryId: 'hot_coffee',
    ),
    Product(
      id: '5',
      name: 'Cold Brew',
      description: 'Café infusionado en frío durante 12 horas',
      price: 11000,
      imageUrl: '',
      categoryId: 'cold_drinks',
    ),
    Product(
      id: '6',
      name: 'Frappé de Caramelo',
      description: 'Bebida helada con crema batida y caramelo',
      price: 14000,
      imageUrl: '',
      categoryId: 'cold_drinks',
    ),
    Product(
      id: '7',
      name: 'Cheesecake de Frutos Rojos',
      description: 'Suave tarta de queso con mermelada artesanal',
      price: 13000,
      imageUrl: '',
      categoryId: 'desserts',
    ),
    Product(
      id: '8',
      name: 'Torta de Chocolate',
      description: 'Bizcocho húmedo de cacao con cobertura fina',
      price: 12500,
      imageUrl: '',
      categoryId: 'desserts',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryBrown = theme.colorScheme.primary;
    const darkBrown = Color(0xFF634832);
    final scaffoldBgColor = theme.scaffoldBackgroundColor;
    final textColor = theme.colorScheme.onSurface;
    final subtitleColor = textColor.withOpacity(0.55);
    final dividerColor = textColor.withOpacity(0.08);
    final outlinedBtnBg = isDark ? theme.cardColor : Colors.white;

    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    // Filtrar productos según la categoría seleccionada
    final selectedCategoryId = _categories[_selectedCategoryIndex]['id'];
    final filteredProducts = _fullMenuProducts
        .where((p) => p.categoryId == selectedCategoryId)
        .toList();

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SECCIÓN HERO CON IMAGEN DE FONDO, GRADIENTE Y ESTADÍSTICAS ---
            // Se mantiene con colores fijos a propósito: es la identidad visual de marca
            // y usa una imagen de fondo, por lo que no debe adaptarse al tema claro/oscuro.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, bottom: 36, left: 20, right: 20),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage('assets/images/hero_home_image.jpeg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.45),
                    BlendMode.darken,
                  ),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    darkBrown.withOpacity(0.7),
                    primaryBrown.withOpacity(0.6),
                    darkBrown.withOpacity(0.85),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.workspace_premium_outlined, color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Café Artesanal Premium',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Icon(
                    Icons.coffee_rounded,
                    size: 54,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),

                  const Text(
                    'SOMOS CafeApp',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (index) => const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Descubre el sabor auténtico del mejor café artesanal',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem('200+', 'Productos'),
                      _buildVerticalDivider(),
                      _buildStatItem('50K+', 'Clientes'),
                      _buildVerticalDivider(),
                      _buildStatItem('4.9', 'Rating'),
                    ],
                  ),
                ],
              ),
            ),

            // --- TARJETA DE OFERTA ESPECIAL ---
            // También se mantiene con gradiente fijo (elemento promocional de marca)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE2CBB4), Color(0xFFB8936C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: primaryBrown.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.auto_awesome, color: Colors.white, size: 14),
                              SizedBox(width: 6),
                              Text(
                                'Oferta Especial del Día',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        const Text(
                          '¡30% de Descuento!',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),

                        Text(
                          'En tu segunda compra del día.\nSolo por tiempo limitado.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 18),

                        ElevatedButton(
                          onPressed: widget.onOrderNow,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: primaryBrown,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Ordenar Ahora',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, size: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFCC00),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '30%',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: Colors.black87,
                              height: 1,
                            ),
                          ),
                          Text(
                            'OFF',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- SECCIÓN CATEGORÍAS ---
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
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Explora nuestro menú',
                    style: TextStyle(
                      fontSize: 13,
                      color: subtitleColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: List.generate(_categories.length, (index) {
                      final cat = _categories[index];
                      final isSelected = _selectedCategoryIndex == index;

                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategoryIndex = index;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: EdgeInsets.only(
                              right: index < _categories.length - 1 ? 12 : 0,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                            decoration: BoxDecoration(
                              // Las tarjetas de categoría mantienen su color pastel de marca,
                              // ya que son de tono claro y sirven como acento visual reconocible.
                              color: cat['bgColor'],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? primaryBrown : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: cat['iconBgColor'],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(cat['icon'], color: cat['iconColor'], size: 24),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  cat['label'],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.bold,
                                    color: Colors.black87,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // --- SECCIÓN LO MÁS POPULAR ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryBrown,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.local_fire_department_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lo Más Popular',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          Text(
                            'Favoritos de nuestros clientes',
                            style: TextStyle(
                              fontSize: 12,
                              color: subtitleColor,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: widget.onOrderNow,
                        child: Row(
                          children: [
                            Text(
                              'Ver todo',
                              style: TextStyle(
                                color: primaryBrown,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 14,
                              color: primaryBrown,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _popularProducts.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.68,
                    ),
                    itemBuilder: (context, index) {
                      final product = _popularProducts[index];
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
                ],
              ),
            ),

            const SizedBox(height: 32),

            // --- DIVISOR "EXPLORA MÁS" ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: dividerColor,
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 12,
                          color: primaryBrown.withOpacity(0.6),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'EXPLORA MÁS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: subtitleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: dividerColor,
                      thickness: 1,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // --- NUESTRO MENÚ COMPLETO (FILTRADO DINÁMICO) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nuestro Menú Completo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Descubre todas nuestras especialidades artesanales',
                    style: TextStyle(
                      fontSize: 12,
                      color: subtitleColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Renderizado condicional si no existen productos en la categoría
                  filteredProducts.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: Text(
                              'No hay productos disponibles en esta categoría',
                              style: TextStyle(color: subtitleColor, fontSize: 14),
                            ),
                          ),
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredProducts.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.68,
                          ),
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];
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
                ],
              ),
            ),

            const SizedBox(height: 28),

            // --- BOTÓN "VER MENÚ COMPLETO" ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: widget.onOrderNow,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: primaryBrown.withOpacity(0.3),
                      width: 1.2,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: outlinedBtnBg,
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
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: primaryBrown,
                        size: 16,
                      ),
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

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 28,
      width: 1,
      color: Colors.white.withOpacity(0.3),
    );
  }
}