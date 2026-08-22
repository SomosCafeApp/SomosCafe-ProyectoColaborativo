import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  final VoidCallback? onOrderNow;

  const WelcomePage({super.key, this.onOrderNow});

  @override
  Widget build(BuildContext context) {
    const primaryBrown = Color(0xFFA2784F);
    const darkBrown = Color(0xFF634832);
    const scaffoldBgColor = Color(0xFFFAF7F2);

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SECCIÓN HERO CON FONDO Y ESTADÍSTICAS ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, bottom: 36, left: 20, right: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    darkBrown,
                    primaryBrown,
                    darkBrown.withOpacity(0.9),
                  ],
                ),
              ),
              child: Column(
                children: [
                  // Badge Superior "Café Artesanal Premium"
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

                  // Icono Taza de Café
                  const Icon(
                    Icons.coffee_rounded,
                    size: 54,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),

                  // Título Principal
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

                  // Estrellas de Calificación
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (index) => const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Descripción
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

                  // Métricas / Estadísticas
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
                        // Badge "Oferta Especial del Día"
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

                        // Título de la oferta
                        const Text(
                          '¡30% de Descuento!',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Subtítulo
                        Text(
                          'En tu segunda compra del día.\nSolo por tiempo limitado.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Botón "Ordenar Ahora"
                        ElevatedButton(
                          onPressed: onOrderNow,
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

                  // Insignia Circular (30% OFF)
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
                  const Text(
                    'Categorías',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Explora nuestro menú',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildCategoryCard(
                          title: 'Cafés\nCalientes',
                          icon: Icons.coffee_rounded,
                          bgColor: const Color(0xFFFEF3D6),
                          iconBgColor: const Color(0xFFF7E2AD),
                          iconColor: const Color(0xFF8C5C2B),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildCategoryCard(
                          title: 'Bebidas\nFrías',
                          icon: Icons.ac_unit_rounded,
                          bgColor: const Color(0xFFE1F5FE),
                          iconBgColor: const Color(0xFFB3E5FC),
                          iconColor: const Color(0xFF0288D1),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildCategoryCard(
                          title: 'Postres',
                          icon: Icons.cake_rounded,
                          bgColor: const Color(0xFFFCE4EC),
                          iconBgColor: const Color(0xFFF8BBD0),
                          iconColor: const Color(0xFFC2185B),
                        ),
                      ),
                    ],
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
                          const Text(
                            'Lo Más Popular',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'Favoritos de nuestros clientes',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: onOrderNow,
                        child: const Row(
                          children: [
                            Text(
                              'Ver todo',
                              style: TextStyle(
                                color: primaryBrown,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 4),
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

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.68,
                    children: [
                      _buildPopularProductCard(
                        name: 'Espresso',
                        description: 'Intenso y aromático, la esencia pura del café',
                        price: '\$8.000 COP',
                        rating: '4.8',
                        primaryBrown: primaryBrown,
                      ),
                      _buildPopularProductCard(
                        name: 'Cappuccino',
                        description: 'Espresso coronado con espuma de leche sedosa',
                        price: '\$12.000 COP',
                        rating: '4.8',
                        primaryBrown: primaryBrown,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required IconData icon,
    required Color bgColor,
    required Color iconBgColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularProductCard({
    required String name,
    required String description,
    required String price,
    required String rating,
    required Color primaryBrown,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Área superior del producto (Placeholder para icono en lugar de imagen estática)
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3EBE1),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.coffee_rounded,
                      color: primaryBrown.withOpacity(0.6),
                      size: 48,
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          rating,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_border_rounded,
                      size: 16,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black.withOpacity(0.5),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PRECIO',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.black.withOpacity(0.4),
                            ),
                          ),
                          Text(
                            price,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: primaryBrown,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.add, color: Colors.white, size: 14),
                          SizedBox(width: 2),
                          Text(
                            'Añadir',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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