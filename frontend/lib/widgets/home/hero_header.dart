import 'package:flutter/material.dart';

import '../../animations/animations.dart';

class HeroHeader extends StatelessWidget {
  /// Cantidad real de productos del menú.
  final int productCount;

  const HeroHeader({super.key, required this.productCount});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fondo con parallax: se mueve más lento que el contenido al
        // hacer scroll.
        ParallaxBackground(
          child: Image.asset(
            'assets/images/hero_home_image.jpeg',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            color: Colors.black.withValues(alpha: 0.55),
            colorBlendMode: BlendMode.darken,
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(top: 60, bottom: 36, left: 20, right: 20),
          // El contenido se desvanece suavemente al bajar.
          child: ScrollFade(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
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
                // Taza con vapor suave.
                const Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.coffee_rounded, size: 54, color: Colors.white),
                    Positioned(
                      top: -26,
                      child: CoffeeSteam(size: 32),
                    ),
                  ],
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
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem('$productCount', productCount == 1 ? 'Producto' : 'Productos'),
                    _buildVerticalDivider(),
                    _buildStatItem('50K+', 'Clientes'),
                    _buildVerticalDivider(),
                    _buildStatItem('4.9', 'Rating'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
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
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 28,
      width: 1,
      color: Colors.white.withValues(alpha: 0.3),
    );
  }
}
