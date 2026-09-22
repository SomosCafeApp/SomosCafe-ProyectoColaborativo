import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';

import '../widgets/product_detail/product_customization_section.dart';
import '../widgets/product_detail/product_hero_image.dart';
import '../widgets/product_detail/quantity_counter.dart';
import '../widgets/product_detail/custom_section_card.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _quantity = 1;
  int _extraShots = 0;

  String _selectedSize = 'Mediano';
  String _selectedType = 'Caliente';
  String _selectedMilk = 'Entera';

  final Set<String> _selectedToppings = {};

  double _calculateTotalPrice() {
    double extra = 0;

    if (_selectedSize == 'Pequeño') extra += 3000;
    if (_selectedSize == 'Grande') extra += 5000;

    if (_selectedMilk == 'Almendra' || _selectedMilk == 'Avena') {
      extra += 1000;
    }
    if (_selectedMilk == 'Soya') extra += 2000;

    extra += _extraShots * 3000;

    for (final topping in _selectedToppings) {
      if (topping == 'Crema batida') extra += 2000;
      if (topping == 'Canela') extra += 1000;
      if (topping == 'Chispas') extra += 2500;
      if (topping == 'Caramelo') extra += 1500;
    }

    return (widget.product.price + extra) * _quantity;
  }

  void _addToCart() {
    final cart = context.read<CartProvider>();
    cart.addToCart(widget.product, quantity: _quantity);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primary = AppColors.primary;
    final cardColor =
        theme.cardTheme.color ?? (isDark ? AppColors.darkSurface : AppColors.lightSurface);
    final textColor = theme.colorScheme.onSurface;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final mutedColor = subtitleColor.withAlpha(150);
    final borderColor = isDark ? Colors.white24 : Colors.black12;
    final selectedBg = isDark ? AppColors.darkSurfaceSubtle : AppColors.catWarm;
    final counterBg = isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle;

    final isFav = context.watch<FavoritesProvider>().isFavorite(widget.product);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(textColor, subtitleColor, isFav),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProductHeroImage(
                      imageUrl: widget.product.imageUrl,
                      placeholderBg: isDark ? AppColors.darkSurfaceSubtle : AppColors.catWarm,
                      primaryColor: primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.product.name,
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.product.description,
                      style: TextStyle(fontSize: 13, color: subtitleColor),
                    ),
                    const SizedBox(height: 16),
                    CustomSectionCard(
                      cardColor: cardColor,
                      textColor: textColor,
                      mutedColor: mutedColor,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$${_calculateTotalPrice().toStringAsFixed(0)} COP',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w900, color: primary),
                          ),
                          QuantityCounter(
                            value: _quantity,
                            counterBtnBg: counterBg,
                            textColor: textColor,
                            onIncrement: () => setState(() => _quantity++),
                            onDecrement: () {
                              if (_quantity > 1) setState(() => _quantity--);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ProductCustomizationSection(
                      cardColor: cardColor,
                      textColor: textColor,
                      mutedColor: mutedColor,
                      selectedBg: selectedBg,
                      primary: primary,
                      borderColor: borderColor,
                      counterBg: counterBg,
                      selectedSize: _selectedSize,
                      selectedType: _selectedType,
                      selectedMilk: _selectedMilk,
                      extraShots: _extraShots,
                      selectedToppings: _selectedToppings,
                      onSizeChanged: (v) => setState(() => _selectedSize = v),
                      onTypeChanged: (v) => setState(() => _selectedType = v),
                      onMilkChanged: (v) => setState(() => _selectedMilk = v),
                      onIncrementShots: () => setState(() => _extraShots++),
                      onDecrementShots: () {
                        if (_extraShots > 0) setState(() => _extraShots--);
                      },
                      onToppingToggle: (v) => setState(() {
                        if (_selectedToppings.contains(v)) {
                          _selectedToppings.remove(v);
                        } else {
                          _selectedToppings.add(v);
                        }
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(cardColor, primary),
    );
  }

  Widget _buildHeader(Color textColor, Color subtitleColor, bool isFav) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Row(
              children: [
                Icon(Icons.arrow_back_ios_new, size: 16, color: textColor),
                const SizedBox(width: 4),
                Text('Volver', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isFav ? Colors.red : subtitleColor,
            ),
            onPressed: () => context.read<FavoritesProvider>().toggleFavorite(widget.product),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(Color cardColor, Color primary) {
    final total = _calculateTotalPrice().toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardColor),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: _addToCart,
        child: Text(
          'Agregar al Carrito (\$$total COP)',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
