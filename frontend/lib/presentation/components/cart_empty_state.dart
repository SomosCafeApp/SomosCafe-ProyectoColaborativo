import 'package:flutter/material.dart';

class CartEmptyState extends StatelessWidget {
  final Color primaryBrown;
  final VoidCallback? onExploreMenu;

  const CartEmptyState({
    super.key,
    required this.primaryBrown,
    this.onExploreMenu,
  });

  @override
  Widget build(BuildContext context) {
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
              Icons.shopping_bag_outlined,
              size: 40,
              color: primaryBrown,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Tu carrito está vacío',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Añade productos para continuar',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onExploreMenu,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBrown,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Explorar Menú',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}