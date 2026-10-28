import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/utils/cart_guard.dart';
import '../models/product_customization.dart';
import '../models/product_model.dart';
import '../providers/auth_provider.dart';
import '../widgets/drink_studio/drink_studio_entry.dart';
import '../widgets/product_detail/product_bottom_bar.dart';
import '../widgets/product_detail/product_customization_section.dart';
import '../widgets/product_detail/product_detail_header.dart';
import '../widgets/product_detail/product_hero_image.dart';
import '../widgets/product_detail/product_ingredients.dart';
import '../widgets/product_detail/product_price_card.dart';
import '../widgets/product_detail/reviews_section.dart';

import '../animations/animations.dart';
class ProductDetailPage extends StatefulWidget {
  final Product product;

  /// Etiqueta del Hero que viene de la tarjeta (null = sin animación).
  final Object? heroTag;

  const ProductDetailPage({super.key, required this.product, this.heroTag});

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

  Product get _product => widget.product;

  final GlobalKey _imageKey = GlobalKey();

  Widget _wrapHero(Widget child) => widget.heroTag == null
      ? child
      : Hero(tag: widget.heroTag!, child: child);

  /// Miniatura que sale de la foto y vuela al carrito.
  void _flyToCart() {
    final box = _imageKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.attached) return;
    final center = (box.localToGlobal(Offset.zero) & box.size).center;
    CartFly.launch(
      context,
      from: Rect.fromCenter(center: center, width: 90, height: 90),
      imageUrl: _product.imageUrl,
    );
  }

  /// Lo que el usuario eligió en pantalla. Es lo que viaja al carrito
  /// y luego al pedido (el backend valida y recalcula el precio).
  /// Los postres no tienen personalización: siempre van con los valores
  /// por defecto (el backend también lo exige).
  ProductCustomization get _customization => !_product.isCustomizable
      ? ProductCustomization()
      : ProductCustomization(
          size: _selectedSize,
          type: _selectedType,
          milk: _selectedMilk,
          extraShots: _extraShots,
          toppings: Set<String>.from(_selectedToppings),
        );

  // El descuento de la promoción aplica al precio base del producto;
  // las personalizaciones se suman sin descuento. El backend recalcula.
  double get _totalPrice => _customization.calculateTotalPrice(_product.effectivePrice, _quantity);

  double get _originalPrice => _customization.calculateTotalPrice(_product.price, _quantity);

  void _addToCart() {
    final isLoggedIn = context.read<AuthProvider>().isLoggedIn;
    CartGuard.addToCart(
      context,
      _product,
      quantity: _quantity,
      customization: _customization,
    );
    // Solo cerramos esta pantalla si sí se pudo agregar (si no había
    // sesión, CartGuard ya mostró el aviso pidiendo iniciar sesión).
    if (isLoggedIn) {
      _flyToCart();
      Navigator.pop(context);
    }
  }

  void _toggleTopping(String topping) => setState(() {
        if (!_selectedToppings.remove(topping)) _selectedToppings.add(topping);
      });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primary = AppColors.primary;
    final cardColor = theme.cardTheme.color ?? (isDark ? AppColors.darkSurface : AppColors.lightSurface);
    final textColor = theme.colorScheme.onSurface;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final placeholderBg = isDark ? AppColors.darkSurfaceSubtle : AppColors.catWarm;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            ProductDetailHeader(product: _product),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _wrapHero(
                      ProductHeroImage(
                        key: _imageKey,
                        imageUrl: _product.imageUrl,
                        placeholderBg: placeholderBg,
                        primaryColor: primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _product.name,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _product.description,
                      style: TextStyle(fontSize: 13, color: subtitleColor),
                    ),
                    ProductIngredients(ingredients: _product.ingredients),
                    const SizedBox(height: 16),
                    ProductPriceCard(
                      product: _product,
                      totalPrice: _totalPrice,
                      originalPrice: _originalPrice,
                      quantity: _quantity,
                      onIncrement: () => setState(() => _quantity++),
                      onDecrement: () {
                        if (_quantity > 1) setState(() => _quantity--);
                      },
                    ),
                    const SizedBox(height: 16),
                    // Postres: sin menú de personalización.
                    if (_product.isCustomizable)
                      ProductCustomizationSection(
                        cardColor: cardColor,
                        textColor: textColor,
                        mutedColor: subtitleColor.withAlpha(150),
                        selectedBg: placeholderBg,
                        primary: primary,
                        borderColor: isDark ? Colors.white24 : Colors.black12,
                        counterBg: isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle,
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
                        onToppingToggle: _toggleTopping,
                      ),
                    ReviewsSection(
                      productId: _product.id,
                      cardColor: cardColor,
                      textColor: textColor,
                      mutedColor: subtitleColor,
                    ),
                    // Espacio para que el botón flotante no tape el final.
                    if (DrinkStudioFab.supports(_product)) const SizedBox(height: 72),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Minijuego opcional: ícono flotante solo en bebidas compatibles.
      floatingActionButton: DrinkStudioFab.supports(_product) ? DrinkStudioFab(product: _product) : null,
      bottomNavigationBar: ProductBottomBar(
        total: _totalPrice,
        isAvailable: _product.isAvailable,
        onAdd: _addToCart,
      ),
    );
  }
}
