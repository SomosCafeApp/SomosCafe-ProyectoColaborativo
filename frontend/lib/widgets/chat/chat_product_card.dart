import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/product_model.dart';
import '../../pages/product_detail_page.dart';

/// Tarjeta compacta de un producto recomendado por el barista virtual.
/// Al tocarla se abre el detalle real del producto (el mismo que se
/// abre desde el menú), con sus opciones de personalización y el botón
/// para agregar al carrito.
class ChatProductCard extends StatelessWidget {
  final Product product;

  const ChatProductCard({super.key, required this.product});

  /// 12500 -> "$12.500"
  static String _formatPrice(double value) {
    final digits = value.round().toString();
    final withDots = digits.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );
    return '\$$withDots';
  }

  void _openDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailPage(product: product),
      ),
    );
  }

  Widget _fallbackImage(Color bg) {
    return Container(
      color: bg,
      alignment: Alignment.center,
      child: const Icon(
        Icons.coffee_rounded,
        color: AppColors.primary,
        size: 28,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final imageBg =
        isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle;

    final hasImage = product.imageUrl.startsWith('http');

    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openDetail(context),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 68,
                    height: 68,
                    child: hasImage
                        ? Image.network(
                            product.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _fallbackImage(imageBg),
                          )
                        : _fallbackImage(imageBg),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        children: [
                          Text(
                            _formatPrice(product.effectivePrice),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (product.hasDiscount)
                            Text(
                              _formatPrice(product.price),
                              style: TextStyle(
                                color: subtitleColor,
                                fontSize: 12,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          if (product.promotionLabel != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accentYellow,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                product.promotionLabel!,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (product.reviewCount > 0) ...[
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: AppColors.accentYellow,
                              size: 15,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              product.rating.toStringAsFixed(1),
                              style: TextStyle(
                                color: subtitleColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: subtitleColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Botones de una tarjeta de producto del chat: elegir/agregar (sigue la
/// conversación y pide confirmación antes de tocar el carrito) y ver
/// los detalles del producto.
class ChatProductActions extends StatelessWidget {
  final Product product;
  final String selectLabel;
  final VoidCallback onSelect;

  const ChatProductActions({
    super.key,
    required this.product,
    required this.selectLabel,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProductDetailPage(product: product)),
              ),
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
              child: const Text('Ver detalles'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FilledButton(
              onPressed: onSelect,
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size(0, 44)),
              child: Text(selectLabel),
            ),
          ),
        ],
      ),
    );
  }
}
