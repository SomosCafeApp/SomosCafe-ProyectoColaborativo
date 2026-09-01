import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/product_card.dart';
import '../../data/models/product.dart';
import '../state/cart_provider.dart';
import '../state/favorites_provider.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _quantity = 1;
  String _selectedSize = 'Mediano';
  String _selectedType = 'Caliente';
  String _selectedMilk = 'Entera';
  String _selectedSugar = 'Normal';
  int _extraShots = 0;
  final Set<String> _selectedToppings = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryBrown = theme.colorScheme.primary;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final cardColor = theme.cardColor;
    final textColor = theme.colorScheme.onSurface;
    final subtitleColor = textColor.withOpacity(0.55);
    final mutedColor = textColor.withOpacity(0.35);
    final borderColor = textColor.withOpacity(0.12);
    final selectedBg = isDark ? primaryBrown.withOpacity(0.18) : const Color(0xFFF3EBE1);
    final imagePlaceholderBg = isDark ? const Color(0xFF3D2E26) : const Color(0xFFF3EBE1);
    final counterBtnBg = isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05);
    final reviewCardBg = isDark ? Colors.white.withOpacity(0.04) : const Color(0xFFFAF7F2).withOpacity(0.6);

    final favoritesProvider = context.watch<FavoritesProvider>();
    final isFavorite = favoritesProvider.isFavorite(widget.product);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER SUPERIOR ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          Icon(Icons.arrow_back_ios_new, size: 16, color: textColor),
                          const SizedBox(width: 4),
                          Text('Volver', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      context.read<FavoritesProvider>().toggleFavorite(widget.product);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: cardColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: isFavorite ? const Color(0xFFE53935) : subtitleColor,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- CONTENIDO SCROLLABLE ---
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // CARRUSEL DE IMÁGENES
                    _buildImageCarousel(imagePlaceholderBg, primaryBrown),

                    const SizedBox(height: 16),

                    // TÍTULO Y DESCRIPCIÓN
                    Text(
                      widget.product.name,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.product.description,
                      style: TextStyle(fontSize: 13, color: subtitleColor),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                        const Icon(Icons.star_half_rounded, color: Colors.amber, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          '4.8 (127 reseñas)',
                          style: TextStyle(fontSize: 12, color: subtitleColor, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // PRECIO
                    _buildCard(
                      cardColor: cardColor,
                      textColor: textColor,
                      mutedColor: mutedColor,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '\$${widget.product.price.toStringAsFixed(0)} COP',
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: primaryBrown),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Precio unitario base',
                                style: TextStyle(fontSize: 11, color: mutedColor),
                              ),
                            ],
                          ),
                          // SELECTOR DE CANTIDAD
                          Row(
                            children: [
                              _buildCounterButton(
                                Icons.remove,
                                counterBtnBg,
                                textColor,
                                () {
                                  if (_quantity > 1) {
                                    setState(() => _quantity--);
                                  }
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                child: Text(
                                  '$_quantity',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                                ),
                              ),
                              _buildCounterButton(
                                Icons.add,
                                counterBtnBg,
                                textColor,
                                () => setState(() => _quantity++),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // TAMAÑO
                    _buildCard(
                      cardColor: cardColor,
                      textColor: textColor,
                      mutedColor: mutedColor,
                      title: 'Tamaño',
                      child: Row(
                        children: [
                          _buildSelectableBox('Pequeño', '8oz', '+\$3.000', _selectedSize == 'Pequeño', () => setState(() => _selectedSize = 'Pequeño'), selectedBg, primaryBrown, borderColor, textColor, mutedColor),
                          const SizedBox(width: 8),
                          _buildSelectableBox('Mediano', '12oz', null, _selectedSize == 'Mediano', () => setState(() => _selectedSize = 'Mediano'), selectedBg, primaryBrown, borderColor, textColor, mutedColor),
                          const SizedBox(width: 8),
                          _buildSelectableBox('Grande', '16oz', '+\$5.000', _selectedSize == 'Grande', () => setState(() => _selectedSize = 'Grande'), selectedBg, primaryBrown, borderColor, textColor, mutedColor),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // TIPO (Caliente / Frío)
                    _buildCard(
                      cardColor: cardColor,
                      textColor: textColor,
                      mutedColor: mutedColor,
                      title: 'Tipo',
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildTypeButton(Icons.thermostat_outlined, 'Caliente', _selectedType == 'Caliente', () => setState(() => _selectedType = 'Caliente'), selectedBg, primaryBrown, borderColor, textColor),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTypeButton(Icons.ac_unit_outlined, 'Frío', _selectedType == 'Frío', () => setState(() => _selectedType = 'Frío'), selectedBg, primaryBrown, borderColor, textColor),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // TIPO DE LECHE
                    _buildCard(
                      cardColor: cardColor,
                      textColor: textColor,
                      mutedColor: mutedColor,
                      title: 'Tipo de Leche',
                      subtitle: 'Opcional',
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        childAspectRatio: 2.2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        children: [
                          _buildOptionChip('Entera', null, _selectedMilk == 'Entera', () => setState(() => _selectedMilk = 'Entera'), selectedBg, primaryBrown, borderColor, textColor, mutedColor),
                          _buildOptionChip('Almendra', '+\$1.000', _selectedMilk == 'Almendra', () => setState(() => _selectedMilk = 'Almendra'), selectedBg, primaryBrown, borderColor, textColor, mutedColor),
                          _buildOptionChip('Avena', '+\$1.000', _selectedMilk == 'Avena', () => setState(() => _selectedMilk = 'Avena'), selectedBg, primaryBrown, borderColor, textColor, mutedColor),
                          _buildOptionChip('Soya', '+\$2.000', _selectedMilk == 'Soya', () => setState(() => _selectedMilk = 'Soya'), selectedBg, primaryBrown, borderColor, textColor, mutedColor),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // AZÚCAR
                    _buildCard(
                      cardColor: cardColor,
                      textColor: textColor,
                      mutedColor: mutedColor,
                      title: 'Nivel de Azúcar',
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: ['Sin azúcar', 'Poco', 'Normal', 'Dulce'].map((level) {
                          final isSel = _selectedSugar == level;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedSugar = level),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSel ? selectedBg : Colors.transparent,
                                border: Border.all(color: isSel ? primaryBrown : borderColor),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                level,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                  color: isSel ? primaryBrown : textColor,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // SHOTS EXTRA
                    _buildCard(
                      cardColor: cardColor,
                      textColor: textColor,
                      mutedColor: mutedColor,
                      title: 'Shots Extra de Espresso',
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Número de shots', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor)),
                          Row(
                            children: [
                              _buildCounterButton(Icons.remove, counterBtnBg, textColor, () {
                                if (_extraShots > 0) setState(() => _extraShots--);
                              }),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text('$_extraShots', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor)),
                              ),
                              _buildCounterButton(Icons.add, counterBtnBg, textColor, () => setState(() => _extraShots++)),
                            ],
                          )
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // TOPPINGS
                    _buildCard(
                      cardColor: cardColor,
                      textColor: textColor,
                      mutedColor: mutedColor,
                      title: 'Toppings',
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        childAspectRatio: 2.2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        children: [
                          _buildToggleChip('Crema batida', '+\$2.000', selectedBg, primaryBrown, borderColor, textColor, mutedColor),
                          _buildToggleChip('Canela', '+\$1.000', selectedBg, primaryBrown, borderColor, textColor, mutedColor),
                          _buildToggleChip('Chispas chocolate', '+\$2.500', selectedBg, primaryBrown, borderColor, textColor, mutedColor),
                          _buildToggleChip('Caramelo', '+\$1.500', selectedBg, primaryBrown, borderColor, textColor, mutedColor),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ENTREGA
                    _buildCard(
                      cardColor: cardColor,
                      textColor: textColor,
                      mutedColor: mutedColor,
                      title: 'Información de Entrega',
                      child: Column(
                        children: [
                          _buildInfoTile(Icons.access_time_rounded, 'Tiempo estimado', '20-30 minutos', selectedBg, primaryBrown, textColor, mutedColor),
                          Divider(height: 16, color: borderColor),
                          _buildInfoTile(Icons.local_shipping_outlined, 'Envío gratuito', 'En compras superiores a \$20.000', selectedBg, primaryBrown, textColor, mutedColor),
                          Divider(height: 16, color: borderColor),
                          _buildInfoTile(Icons.location_on_outlined, 'Recogida en tienda', 'Punto principal disponible', selectedBg, primaryBrown, textColor, mutedColor),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // RESEÑAS
                    _buildCard(
                      cardColor: cardColor,
                      textColor: textColor,
                      mutedColor: mutedColor,
                      title: 'Reseñas',
                      child: Column(
                        children: [
                          _buildReviewItem('María García', 'Excelente café, muy aromático y de calidad premium', 'Hace 2 días', 5, reviewCardBg, textColor, mutedColor),
                          const SizedBox(height: 10),
                          _buildReviewItem('Carlos López', 'Muy buen sabor y temperatura perfecta.', 'Hace 1 semana', 4, reviewCardBg, textColor, mutedColor),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // PRODUCTOS RELACIONADOS
                    Text(
                      'Productos Relacionados',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 240,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          SizedBox(
                            width: 170,
                            child: ProductCard(
                              product: Product(
                                id: 'rel1',
                                name: 'Cappuccino',
                                description: 'Espresso con leche y espuma abundante',
                                price: 12000,
                                imageUrl: '',
                              ),
                              onAddToCart: () {},
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 170,
                            child: ProductCard(
                              product: Product(
                                id: 'rel2',
                                name: 'Flat White',
                                description: 'Café suave con microespuma artesanal',
                                price: 13000,
                                imageUrl: '',
                              ),
                              onAddToCart: () {},
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // --- BARRA INFERIOR DE AGREGAR AL CARRITO ---
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBrown,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          onPressed: () {
            // Agregamos el producto según la cantidad elegida
            for (int i = 0; i < _quantity; i++) {
              context.read<CartProvider>().addToCart(widget.product);
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$_quantity x ${widget.product.name} agregados al carrito'),
                duration: const Duration(seconds: 2),
                backgroundColor: primaryBrown,
              ),
            );

            Navigator.pop(context);
          },
          icon: const Icon(Icons.add_shopping_cart_rounded, color: Colors.white),
          label: Text(
            'Agregar al Carrito (\$${(widget.product.price * _quantity).toStringAsFixed(0)} COP)',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildImageCarousel(Color placeholderBg, Color primaryBrown) {
    return Stack(
      children: [
        Container(
          height: 280,
          width: double.infinity,
          decoration: BoxDecoration(
            color: placeholderBg,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: Icon(
              Icons.coffee_rounded,
              size: 64,
              color: primaryBrown,
            ),
          ),
        ),
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFF3B30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '20% OFF',
              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard({
    required Color cardColor,
    required Color textColor,
    required Color mutedColor,
    String? title,
    String? subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
                if (subtitle != null)
                  Text(subtitle, style: TextStyle(fontSize: 10, color: mutedColor)),
              ],
            ),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }

  Widget _buildSelectableBox(String title, String subtitle, String? extraPrice, bool isSelected, VoidCallback onTap,
      Color selectedBg, Color primaryBrown, Color borderColor, Color textColor, Color mutedColor) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? selectedBg : Colors.transparent,
            border: Border.all(color: isSelected ? primaryBrown : borderColor),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? primaryBrown : textColor)),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(fontSize: 10, color: mutedColor)),
              if (extraPrice != null) ...[
                const SizedBox(height: 2),
                Text(extraPrice, style: TextStyle(fontSize: 9, color: mutedColor)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeButton(IconData icon, String label, bool isSelected, VoidCallback onTap,
      Color selectedBg, Color primaryBrown, Color borderColor, Color textColor) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : Colors.transparent,
          border: Border.all(color: isSelected ? primaryBrown : borderColor),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: isSelected ? primaryBrown : textColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? primaryBrown : textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionChip(String title, String? price, bool isSelected, VoidCallback onTap,
      Color selectedBg, Color primaryBrown, Color borderColor, Color textColor, Color mutedColor) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : Colors.transparent,
          border: Border.all(color: isSelected ? primaryBrown : borderColor),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: textColor)),
            if (price != null) Text(price, style: TextStyle(fontSize: 9, color: mutedColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleChip(String title, String price, Color selectedBg, Color primaryBrown, Color borderColor, Color textColor, Color mutedColor) {
    final isSelected = _selectedToppings.contains(title);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedToppings.remove(title);
          } else {
            _selectedToppings.add(title);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : Colors.transparent,
          border: Border.all(color: isSelected ? primaryBrown : borderColor),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: TextStyle(fontSize: 10, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: textColor)),
            Text(price, style: TextStyle(fontSize: 8, color: mutedColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterButton(IconData icon, Color bgColor, Color iconColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: iconColor),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle, Color iconBg, Color iconColor, Color textColor, Color mutedColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
            Text(subtitle, style: TextStyle(fontSize: 10, color: mutedColor)),
          ],
        )
      ],
    );
  }

  Widget _buildReviewItem(String name, String comment, String date, int stars, Color cardBg, Color textColor, Color mutedColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    Icons.star_rounded,
                    size: 12,
                    color: index < stars ? Colors.amber : mutedColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(comment, style: TextStyle(fontSize: 11, color: textColor.withOpacity(0.85))),
          const SizedBox(height: 4),
          Text(date, style: TextStyle(fontSize: 9, color: mutedColor)),
        ],
      ),
    );
  }
}