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
    const primaryBrown = Color(0xFF8C6239);
    const backgroundColor = Color(0xFFFAF7F2);

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
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.black87),
                          SizedBox(width: 4),
                          Text('Volver', style: TextStyle(fontWeight: FontWeight.bold)),
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
                        color: Colors.white,
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
                        color: isFavorite ? const Color(0xFFE53935) : Colors.black54,
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
                    _buildImageCarousel(),

                    const SizedBox(height: 16),

                    // TÍTULO Y DESCRIPCIÓN
                    Text(
                      widget.product.name,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.product.description,
                      style: TextStyle(fontSize: 13, color: Colors.black.withOpacity(0.6)),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                        Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                        Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                        Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                        Icon(Icons.star_half_rounded, color: Colors.amber, size: 18),
                        SizedBox(width: 6),
                        Text(
                          '4.8 (127 reseñas)',
                          style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // PRECIO
                    _buildCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '\$${widget.product.price.toStringAsFixed(0)} COP',
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: primaryBrown),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Precio unitario base',
                                style: TextStyle(fontSize: 11, color: Colors.black45),
                              ),
                            ],
                          ),
                          // SELECTOR DE CANTIDAD
                          Row(
                            children: [
                              _buildCounterButton(
                                Icons.remove,
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
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                              _buildCounterButton(
                                Icons.add,
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
                      title: 'Tamaño',
                      child: Row(
                        children: [
                          _buildSelectableBox('Pequeño', '8oz', '+\$3.000', _selectedSize == 'Pequeño', () => setState(() => _selectedSize = 'Pequeño')),
                          const SizedBox(width: 8),
                          _buildSelectableBox('Mediano', '12oz', null, _selectedSize == 'Mediano', () => setState(() => _selectedSize = 'Mediano')),
                          const SizedBox(width: 8),
                          _buildSelectableBox('Grande', '16oz', '+\$5.000', _selectedSize == 'Grande', () => setState(() => _selectedSize = 'Grande')),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // TIPO (Caliente / Frío)
                    _buildCard(
                      title: 'Tipo',
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildTypeButton(Icons.thermostat_outlined, 'Caliente', _selectedType == 'Caliente', () => setState(() => _selectedType = 'Caliente')),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTypeButton(Icons.ac_unit_outlined, 'Frío', _selectedType == 'Frío', () => setState(() => _selectedType = 'Frío')),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // TIPO DE LECHE
                    _buildCard(
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
                          _buildOptionChip('Entera', null, _selectedMilk == 'Entera', () => setState(() => _selectedMilk = 'Entera')),
                          _buildOptionChip('Almendra', '+\$1.000', _selectedMilk == 'Almendra', () => setState(() => _selectedMilk = 'Almendra')),
                          _buildOptionChip('Avena', '+\$1.000', _selectedMilk == 'Avena', () => setState(() => _selectedMilk = 'Avena')),
                          _buildOptionChip('Soya', '+\$2.000', _selectedMilk == 'Soya', () => setState(() => _selectedMilk = 'Soya')),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // AZÚCAR
                    _buildCard(
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
                                color: isSel ? const Color(0xFFF3EBE1) : Colors.transparent,
                                border: Border.all(color: isSel ? primaryBrown : Colors.black12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                level,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                  color: isSel ? primaryBrown : Colors.black87,
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
                      title: 'Shots Extra de Espresso',
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Número de shots', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              _buildCounterButton(Icons.remove, () {
                                if (_extraShots > 0) setState(() => _extraShots--);
                              }),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text('$_extraShots', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                              ),
                              _buildCounterButton(Icons.add, () => setState(() => _extraShots++)),
                            ],
                          )
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // TOPPINGS
                    _buildCard(
                      title: 'Toppings',
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        childAspectRatio: 2.2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        children: [
                          _buildToggleChip('Crema batida', '+\$2.000'),
                          _buildToggleChip('Canela', '+\$1.000'),
                          _buildToggleChip('Chispas chocolate', '+\$2.500'),
                          _buildToggleChip('Caramelo', '+\$1.500'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ENTREGA
                    _buildCard(
                      title: 'Información de Entrega',
                      child: Column(
                        children: [
                          _buildInfoTile(Icons.access_time_rounded, 'Tiempo estimado', '20-30 minutos'),
                          const Divider(height: 16),
                          _buildInfoTile(Icons.local_shipping_outlined, 'Envío gratuito', 'En compras superiores a \$20.000'),
                          const Divider(height: 16),
                          _buildInfoTile(Icons.location_on_outlined, 'Recogida en tienda', 'Punto principal disponible'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // RESEÑAS
                    _buildCard(
                      title: 'Reseñas',
                      child: Column(
                        children: [
                          _buildReviewItem('María García', 'Excelente café, muy aromático y de calidad premium', 'Hace 2 días', 5),
                          const SizedBox(height: 10),
                          _buildReviewItem('Carlos López', 'Muy buen sabor y temperatura perfecta.', 'Hace 1 semana', 4),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // PRODUCTOS RELACIONADOS
                    const Text(
                      'Productos Relacionados',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
          color: Colors.white,
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

  Widget _buildImageCarousel() {
    return Stack(
      children: [
        Container(
          height: 280,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF3EBE1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Center(
            child: Icon(
              Icons.coffee_rounded,
              size: 64,
              color: Color(0xFF8C6239),
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

  Widget _buildCard({String? title, String? subtitle, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                if (subtitle != null)
                  Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.black45)),
              ],
            ),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }

  Widget _buildSelectableBox(String title, String subtitle, String? extraPrice, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF3EBE1) : Colors.transparent,
            border: Border.all(color: isSelected ? const Color(0xFF8C6239) : Colors.black12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? const Color(0xFF8C6239) : Colors.black87)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.black45)),
              if (extraPrice != null) ...[
                const SizedBox(height: 2),
                Text(extraPrice, style: const TextStyle(fontSize: 9, color: Colors.black45)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeButton(IconData icon, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF3EBE1) : Colors.transparent,
          border: Border.all(color: isSelected ? const Color(0xFF8C6239) : Colors.black12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: isSelected ? const Color(0xFF8C6239) : Colors.black87),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFF8C6239) : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionChip(String title, String? price, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF3EBE1) : Colors.transparent,
          border: Border.all(color: isSelected ? const Color(0xFF8C6239) : Colors.black12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            if (price != null) Text(price, style: const TextStyle(fontSize: 9, color: Colors.black45)),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleChip(String title, String price) {
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
          color: isSelected ? const Color(0xFFF3EBE1) : Colors.transparent,
          border: Border.all(color: isSelected ? const Color(0xFF8C6239) : Colors.black12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: TextStyle(fontSize: 10, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            Text(price, style: const TextStyle(fontSize: 8, color: Colors.black45)),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: Colors.black87),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF3EBE1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF8C6239)),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.black45)),
          ],
        )
      ],
    );
  }

  Widget _buildReviewItem(String name, String comment, String date, int stars) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7F2).withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    Icons.star_rounded,
                    size: 12,
                    color: index < stars ? Colors.amber : Colors.black26,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(comment, style: const TextStyle(fontSize: 11, color: Colors.black87)),
          const SizedBox(height: 4),
          Text(date, style: const TextStyle(fontSize: 9, color: Colors.black38)),
        ],
      ),
    );
  }
}