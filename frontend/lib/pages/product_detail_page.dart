import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';

import '../widgets/product_detail/custom_chip_grid.dart';
import '../widgets/product_detail/custom_section_card.dart';
import '../widgets/product_detail/delivery_info_section.dart';
import '../widgets/product_detail/option_selectable_box.dart';
import '../widgets/product_detail/product_image_carousel.dart';
import '../widgets/product_detail/quantity_counter.dart';
import '../widgets/product_detail/type_selector.dart';

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

  // ─────────────────────────────────────────────
  // PRECIO
  // ─────────────────────────────────────────────

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

  // BUILD PRINCIPAL

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primary = AppColors.primary;
    final cardColor = theme.cardTheme.color ??
        (isDark ? AppColors.darkSurface : AppColors.lightSurface);

    final textColor = theme.colorScheme.onSurface;
    final subtitleColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final mutedColor = subtitleColor.withAlpha(150);
    final borderColor = isDark ? Colors.white24 : Colors.black12;
    final selectedBg =
        isDark ? AppColors.darkSurfaceSubtle : AppColors.catWarm;
    final counterBg =
        isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle;

    final isFav =
        context.watch<FavoritesProvider>().isFavorite(widget.product);

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
                    _buildProductImage(isDark, primary),
                    const SizedBox(height: 16),
                    _buildProductInfo(textColor, subtitleColor),
                    const SizedBox(height: 16),
                    _buildPriceSection(
                      cardColor,
                      textColor,
                      mutedColor,
                      counterBg,
                      primary,
                    ),
                    const SizedBox(height: 16),
                    _buildSizeSection(
                      cardColor,
                      textColor,
                      mutedColor,
                      selectedBg,
                      primary,
                      borderColor,
                    ),
                    const SizedBox(height: 16),
                    _buildTypeSection(
                      cardColor,
                      textColor,
                      mutedColor,
                      selectedBg,
                      primary,
                      borderColor,
                    ),
                    const SizedBox(height: 16),
                    _buildMilkSection(
                      cardColor,
                      textColor,
                      mutedColor,
                      selectedBg,
                      primary,
                      borderColor,
                    ),
                    const SizedBox(height: 16),
                    _buildShotsSection(
                      cardColor,
                      textColor,
                      mutedColor,
                      counterBg,
                    ),
                    const SizedBox(height: 16),
                    _buildToppingsSection(
                      cardColor,
                      textColor,
                      mutedColor,
                      selectedBg,
                      primary,
                      borderColor,
                    ),
                    const SizedBox(height: 16),
                    _buildDeliverySection(
                      cardColor,
                      textColor,
                      mutedColor,
                      selectedBg,
                      primary,
                      borderColor,
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

  // HEADER

  Widget _buildHeader(
    Color textColor,
    Color subtitleColor,
    bool isFav,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Row(
              children: [
                Icon(
                  Icons.arrow_back_ios_new,
                  size: 16,
                  color: textColor,
                ),
                const SizedBox(width: 4),
                Text(
                  'Volver',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              isFav
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: isFav ? Colors.red : subtitleColor,
            ),
            onPressed: () => context
                .read<FavoritesProvider>()
                .toggleFavorite(widget.product),
          ),
        ],
      ),
    );
  }

  // PRODUCTO

  Widget _buildProductImage(bool isDark, Color primary) {
    return ProductImageCarousel(
      placeholderBg:
          isDark ? AppColors.darkSurfaceSubtle : AppColors.catWarm,
      primaryColor: primary,
    );
  }

  Widget _buildProductInfo(
    Color textColor,
    Color subtitleColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.product.name,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.product.description,
          style: TextStyle(
            fontSize: 13,
            color: subtitleColor,
          ),
        ),
      ],
    );
  }

  // PRECIO Y CANTIDAD

  Widget _buildPriceSection(
    Color cardColor,
    Color textColor,
    Color mutedColor,
    Color counterBg,
    Color primary,
  ) {
    return CustomSectionCard(
      cardColor: cardColor,
      textColor: textColor,
      mutedColor: mutedColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '\$${_calculateTotalPrice().toStringAsFixed(0)} COP',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: primary,
            ),
          ),
          QuantityCounter(
            value: _quantity,
            counterBtnBg: counterBg,
            textColor: textColor,
            onIncrement: () => setState(() => _quantity++),
            onDecrement: () {
              if (_quantity > 1) {
                setState(() => _quantity--);
              }
            },
          ),
        ],
      ),
    );
  }

  // TAMAÑO

  Widget _buildSizeSection(
    Color cardColor,
    Color textColor,
    Color mutedColor,
    Color selectedBg,
    Color primary,
    Color borderColor,
  ) {
    return CustomSectionCard(
      cardColor: cardColor,
      textColor: textColor,
      mutedColor: mutedColor,
      title: 'Tamaño',
      child: Row(
        children: [
          _sizeOption(
            'Pequeño',
            '8oz',
            '+\$3.000',
            selectedBg,
            primary,
            borderColor,
            textColor,
            mutedColor,
          ),
          const SizedBox(width: 8),
          _sizeOption(
            'Mediano',
            '12oz',
            null,
            selectedBg,
            primary,
            borderColor,
            textColor,
            mutedColor,
          ),
          const SizedBox(width: 8),
          _sizeOption(
            'Grande',
            '16oz',
            '+\$5.000',
            selectedBg,
            primary,
            borderColor,
            textColor,
            mutedColor,
          ),
        ],
      ),
    );
  }

  Widget _sizeOption(
    String title,
    String subtitle,
    String? price,
    Color selectedBg,
    Color primary,
    Color borderColor,
    Color textColor,
    Color mutedColor,
  ) {
    return OptionSelectableBox(
      title: title,
      subtitle: subtitle,
      extraPrice: price,
      isSelected: _selectedSize == title,
      onTap: () => setState(() => _selectedSize = title),
      selectedBg: selectedBg,
      primaryColor: primary,
      borderColor: borderColor,
      textColor: textColor,
      mutedColor: mutedColor,
    );
  }

  // ─────────────────────────────────────────────
  // TIPO
  // ─────────────────────────────────────────────

  Widget _buildTypeSection(
    Color cardColor,
    Color textColor,
    Color mutedColor,
    Color selectedBg,
    Color primary,
    Color borderColor,
  ) {
    return CustomSectionCard(
      cardColor: cardColor,
      textColor: textColor,
      mutedColor: mutedColor,
      title: 'Tipo',
      child: TypeSelector(
        selectedType: _selectedType,
        onChanged: (value) => setState(() => _selectedType = value),
        selectedBg: selectedBg,
        primaryColor: primary,
        borderColor: borderColor,
        textColor: textColor,
      ),
    );
  }

  // LECHE

  Widget _buildMilkSection(
    Color cardColor,
    Color textColor,
    Color mutedColor,
    Color selectedBg,
    Color primary,
    Color borderColor,
  ) {
    return CustomSectionCard(
      cardColor: cardColor,
      textColor: textColor,
      mutedColor: mutedColor,
      title: 'Tipo de Leche',
      subtitle: 'Opcional',
      child: CustomChipGrid(
        options: const [
          {'title': 'Entera'},
          {'title': 'Almendra', 'price': '+\$1.000'},
          {'title': 'Avena', 'price': '+\$1.000'},
          {'title': 'Soya', 'price': '+\$2.000'},
        ],
        selectedValue: _selectedMilk,
        onTap: (value) => setState(() => _selectedMilk = value),
        selectedBg: selectedBg,
        primaryColor: primary,
        borderColor: borderColor,
        textColor: textColor,
        mutedColor: mutedColor,
      ),
    );
  }

  // SHOTS

  Widget _buildShotsSection(
    Color cardColor,
    Color textColor,
    Color mutedColor,
    Color counterBg,
  ) {
    return CustomSectionCard(
      cardColor: cardColor,
      textColor: textColor,
      mutedColor: mutedColor,
      title: 'Shots Extra',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Shots de espresso',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          QuantityCounter(
            value: _extraShots,
            counterBtnBg: counterBg,
            textColor: textColor,
            onIncrement: () => setState(() => _extraShots++),
            onDecrement: () {
              if (_extraShots > 0) {
                setState(() => _extraShots--);
              }
            },
          ),
        ],
      ),
    );
  }

  // TOPPINGS

  Widget _buildToppingsSection(
    Color cardColor,
    Color textColor,
    Color mutedColor,
    Color selectedBg,
    Color primary,
    Color borderColor,
  ) {
    return CustomSectionCard(
      cardColor: cardColor,
      textColor: textColor,
      mutedColor: mutedColor,
      title: 'Toppings',
      child: CustomChipGrid(
        options: const [
          {'title': 'Crema batida', 'price': '+\$2.000'},
          {'title': 'Canela', 'price': '+\$1.000'},
          {'title': 'Chispas', 'price': '+\$2.500'},
          {'title': 'Caramelo', 'price': '+\$1.500'},
        ],
        selectedSet: _selectedToppings,
        onTap: (value) {
          setState(() {
            if (_selectedToppings.contains(value)) {
              _selectedToppings.remove(value);
            } else {
              _selectedToppings.add(value);
            }
          });
        },
        selectedBg: selectedBg,
        primaryColor: primary,
        borderColor: borderColor,
        textColor: textColor,
        mutedColor: mutedColor,
      ),
    );
  }

  // ENTREGA

  Widget _buildDeliverySection(
    Color cardColor,
    Color textColor,
    Color mutedColor,
    Color selectedBg,
    Color primary,
    Color borderColor,
  ) {
    return CustomSectionCard(
      cardColor: cardColor,
      textColor: textColor,
      mutedColor: mutedColor,
      title: 'Entrega',
      child: DeliveryInfoSection(
        iconBg: selectedBg,
        iconColor: primary,
        textColor: textColor,
        mutedColor: mutedColor,
        borderColor: borderColor,
      ),
    );
  }

  // BOTÓN INFERIOR

  Widget _buildBottomBar(Color cardColor, Color primary) {
    final total = _calculateTotalPrice().toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardColor),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: _addToCart,
        child: Text(
          'Agregar al Carrito (\$$total COP)',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _addToCart() {
    final cart = context.read<CartProvider>();

    for (int i = 0; i < _quantity; i++) {
      cart.addToCart(widget.product);
    }

    Navigator.pop(context);
  }
}