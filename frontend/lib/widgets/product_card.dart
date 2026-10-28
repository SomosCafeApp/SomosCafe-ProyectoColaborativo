import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/favorites_guard.dart';
import '../models/product_model.dart';
import '../pages/product_detail_page.dart';
import '../providers/favorites_provider.dart';

import '../animations/animations.dart';
import '../providers/auth_provider.dart';
class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    required this.onAddToCart,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  // Etiqueta única por tarjeta: así la foto "vuela" al detalle sin chocar
  // con el mismo producto mostrado en otra pestaña.
  final Object _heroTag = UniqueKey();

  Product get product => widget.product;
  VoidCallback get onAddToCart => widget.onAddToCart;

  /// Lanza la miniatura hacia el carrito (solo si hay sesión iniciada,
  /// que es cuando el producto sí se agrega).
  void _flyFrom(BuildContext fromContext) {
    if (!context.read<AuthProvider>().isLoggedIn) return;
    final box = fromContext.findRenderObject();
    if (box is! RenderBox || !box.attached) return;
    CartFly.launch(
      context,
      from: box.localToGlobal(Offset.zero) & box.size,
      imageUrl: product.imageUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Paleta de colores ajustada a AppColors y Figma
    final cardColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final mutedColor = subtitleColor.withValues(alpha: 0.7);
    
    final imagePlaceholderBg = isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle;
    final pillBg = isDark ? AppColors.darkSurfaceSubtle.withValues(alpha: 0.85) : Colors.white.withValues(alpha: 0.9);
    final viewsBadgeBg = isDark ? AppColors.darkSurfaceSubtle.withValues(alpha: 0.92) : AppColors.lightSurfaceSubtle.withValues(alpha: 0.92);
    final viewsIconColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final viewsTextColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    final actionBtnBg = AppColors.primary;
    final actionBtnTextColor = Colors.white;

    final bool hasImage = product.imageUrl.isNotEmpty;

    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final isFav = favoritesProvider.isFavorite(product);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailPage(product: product, heroTag: _heroTag),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- IMAGEN / HEADER CON BADGES ---
              Expanded(
                child: Stack(
                  children: [
                    // Imagen sin bordes ni padding
                    Positioned.fill(
                      child: Hero(
                        tag: _heroTag,
                        child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        child: Container(
                          color: imagePlaceholderBg,
                          child: hasImage
                              ? (product.imageUrl.startsWith('http')
                                  ? Image.network(
                                      product.imageUrl,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          _buildFallbackIcon(AppColors.primary),
                                    )
                                  : Image.asset(
                                      product.imageUrl,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          _buildFallbackIcon(AppColors.primary),
                                    ))
                              : _buildFallbackIcon(AppColors.primary),
                        ),
                      ),
                      ),
                    ),

                    // 1. RATING STAR (Arriba a la izquierda)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: pillBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: 14,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              product.reviewCount > 0
                                  ? product.rating.toStringAsFixed(1)
                                  : 'Nuevo',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 2. BOTÓN DE FAVORITO (Arriba a la derecha)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => FavoritesGuard.toggleFavorite(context, product),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: pillBg,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: HeartPop(
                            active: isFav,
                            child: Icon(
                              isFav
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: isFav
                                  ? const Color(0xFFE53935)
                                  : subtitleColor,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ),


                    // 2b. BADGE DE PROMOCIÓN (Abajo a la izquierda)
                    if (product.hasDiscount && (product.promotionLabel ?? '').isNotEmpty)
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.accentYellow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            product.promotionLabel!,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),

                    // 3. BADGE DE VISTAS (Abajo a la derecha)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: viewsBadgeBg,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.favorite,
                              size: 14,
                              color: viewsIconColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${product.favoritesCount}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: viewsTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // --- INFORMACIÓN DEL PRODUCTO ---
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        color: subtitleColor,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PRECIO',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: mutedColor,
                              ),
                            ),
                            if (product.hasDiscount)
                              Text(
                                '\$${product.price.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: mutedColor,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            Text(
                              '\$${product.effectivePrice.toStringAsFixed(0)} COP',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: product.hasDiscount ? AppColors.primary : textColor,
                              ),
                            ),
                          ],
                        ),
                        Builder(
                          builder: (btnContext) => PressScale(
                          onTap: () {
                            _flyFrom(btnContext);
                            onAddToCart();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: actionBtnBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.add_rounded,
                                  color: actionBtnTextColor,
                                  size: 14,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  'Añadir',
                                  style: TextStyle(
                                    color: actionBtnTextColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackIcon(Color color) {
    return Center(
      child: Icon(
        Icons.coffee_rounded,
        color: color.withValues(alpha: 0.4),
        size: 38,
      ),
    );
  }
}