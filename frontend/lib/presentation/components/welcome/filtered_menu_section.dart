import 'package:flutter/material.dart';
import '../../../data/models/product.dart';
import '../product_card/product_card.dart';

class FilteredMenuSection extends StatelessWidget {
  final List<Product> products;
  final Function(Product) onAddToCart;

  const FilteredMenuSection({
    super.key,
    required this.products,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitleColor = theme.colorScheme.onSurface.withOpacity(0.55);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nuestro Menú Completo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 2),
          Text('Descubre todas nuestras especialidades artesanales', style: TextStyle(fontSize: 12, color: subtitleColor)),
          const SizedBox(height: 16),
          products.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text('No hay productos disponibles en esta categoría', style: TextStyle(color: subtitleColor, fontSize: 14)),
                  ),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.68,
                  ),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductCard(
                      product: product,
                      onAddToCart: () => onAddToCart(product),
                    );
                  },
                ),
        ],
      ),
    );
  }
}