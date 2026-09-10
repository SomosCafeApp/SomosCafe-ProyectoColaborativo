import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/product_detail/custom_chip_grid.dart';
import '../components/product_detail/custom_section_card.dart';
import '../components/product_detail/delivery_info_section.dart';
import '../components/product_detail/option_selectable_box.dart';
import '../components/product_detail/product_image_carousel.dart';
import '../components/product_detail/quantity_counter.dart';
import '../components/product_detail/type_selector.dart';

import '../../data/models/product.dart';
import '../state/cart_provider.dart';
import '../state/favorites_provider.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;
  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _quantity = 1, _extraShots = 0;
  String _selectedSize = 'Mediano', _selectedType = 'Caliente', _selectedMilk = 'Entera';
  final Set<String> _selectedToppings = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final cardColor = theme.cardColor;
    final textColor = theme.colorScheme.onSurface;
    final subtitleColor = textColor.withOpacity(0.55), mutedColor = textColor.withOpacity(0.35), borderColor = textColor.withOpacity(0.12);
    final selectedBg = isDark ? primary.withOpacity(0.18) : const Color(0xFFF3EBE1);
    final counterBg = isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05);
    final isFav = context.watch<FavoritesProvider>().isFavorite(widget.product);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Row(children: [Icon(Icons.arrow_back_ios_new, size: 16, color: textColor), const SizedBox(width: 4), Text('Volver', style: TextStyle(fontWeight: FontWeight.bold, color: textColor))]),
                  ),
                  IconButton(
                    icon: Icon(isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: isFav ? Colors.red : subtitleColor),
                    onPressed: () => context.read<FavoritesProvider>().toggleFavorite(widget.product),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProductImageCarousel(placeholderBg: isDark ? const Color(0xFF3D2E26) : const Color(0xFFF3EBE1), primaryColor: primary),
                    const SizedBox(height: 16),
                    Text(widget.product.name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
                    Text(widget.product.description, style: TextStyle(fontSize: 13, color: subtitleColor)),
                    const SizedBox(height: 16),
                    CustomSectionCard(
                      cardColor: cardColor, textColor: textColor, mutedColor: mutedColor,
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('\$${widget.product.price.toStringAsFixed(0)} COP', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: primary)),
                        QuantityCounter(value: _quantity, counterBtnBg: counterBg, textColor: textColor, onIncrement: () => setState(() => _quantity++), onDecrement: () => setState(() { if (_quantity > 1) _quantity--; })),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    CustomSectionCard(
                      cardColor: cardColor, textColor: textColor, mutedColor: mutedColor, title: 'Tamaño',
                      child: Row(children: [
                        OptionSelectableBox(title: 'Pequeño', subtitle: '8oz', extraPrice: '+\$3.000', isSelected: _selectedSize == 'Pequeño', onTap: () => setState(() => _selectedSize = 'Pequeño'), selectedBg: selectedBg, primaryColor: primary, borderColor: borderColor, textColor: textColor, mutedColor: mutedColor),
                        const SizedBox(width: 8),
                        OptionSelectableBox(title: 'Mediano', subtitle: '12oz', isSelected: _selectedSize == 'Mediano', onTap: () => setState(() => _selectedSize = 'Mediano'), selectedBg: selectedBg, primaryColor: primary, borderColor: borderColor, textColor: textColor, mutedColor: mutedColor),
                        const SizedBox(width: 8),
                        OptionSelectableBox(title: 'Grande', subtitle: '16oz', extraPrice: '+\$5.000', isSelected: _selectedSize == 'Grande', onTap: () => setState(() => _selectedSize = 'Grande'), selectedBg: selectedBg, primaryColor: primary, borderColor: borderColor, textColor: textColor, mutedColor: mutedColor),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    CustomSectionCard(cardColor: cardColor, textColor: textColor, mutedColor: mutedColor, title: 'Tipo', child: TypeSelector(selectedType: _selectedType, onChanged: (v) => setState(() => _selectedType = v), selectedBg: selectedBg, primaryColor: primary, borderColor: borderColor, textColor: textColor)),
                    const SizedBox(height: 16),
                    CustomSectionCard(cardColor: cardColor, textColor: textColor, mutedColor: mutedColor, title: 'Tipo de Leche', subtitle: 'Opcional', child: CustomChipGrid(options: const [{'title': 'Entera'}, {'title': 'Almendra', 'price': '+\$1.000'}, {'title': 'Avena', 'price': '+\$1.000'}, {'title': 'Soya', 'price': '+\$2.000'}], selectedValue: _selectedMilk, onTap: (v) => setState(() => _selectedMilk = v), selectedBg: selectedBg, primaryColor: primary, borderColor: borderColor, textColor: textColor, mutedColor: mutedColor)),
                    const SizedBox(height: 16),
                    CustomSectionCard(cardColor: cardColor, textColor: textColor, mutedColor: mutedColor, title: 'Shots Extra', child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Shots de espresso', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor)), QuantityCounter(value: _extraShots, counterBtnBg: counterBg, textColor: textColor, onIncrement: () => setState(() => _extraShots++), onDecrement: () => setState(() { if (_extraShots > 0) _extraShots--; }))])),
                    const SizedBox(height: 16),
                    CustomSectionCard(cardColor: cardColor, textColor: textColor, mutedColor: mutedColor, title: 'Toppings', child: CustomChipGrid(options: const [{'title': 'Crema batida', 'price': '+\$2.000'}, {'title': 'Canela', 'price': '+\$1.000'}, {'title': 'Chispas', 'price': '+\$2.500'}, {'title': 'Caramelo', 'price': '+\$1.500'}], selectedSet: _selectedToppings, onTap: (v) => setState(() => _selectedToppings.contains(v) ? _selectedToppings.remove(v) : _selectedToppings.add(v)), selectedBg: selectedBg, primaryColor: primary, borderColor: borderColor, textColor: textColor, mutedColor: mutedColor)),
                    const SizedBox(height: 16),
                    CustomSectionCard(cardColor: cardColor, textColor: textColor, mutedColor: mutedColor, title: 'Entrega', child: DeliveryInfoSection(iconBg: selectedBg, iconColor: primary, textColor: textColor, mutedColor: mutedColor, borderColor: borderColor)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: cardColor),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: primary, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
          onPressed: () {
            for (int i = 0; i < _quantity; i++) context.read<CartProvider>().addToCart(widget.product);
            Navigator.pop(context);
          },
          child: Text('Agregar al Carrito (\$${(widget.product.price * _quantity).toStringAsFixed(0)} COP)', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
    );
  }
}