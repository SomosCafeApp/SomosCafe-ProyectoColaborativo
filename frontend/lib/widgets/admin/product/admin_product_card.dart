import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/category_labels.dart';
import '../../../models/product_model.dart';

/// Tarjeta de un producto en el panel admin. Acciones:
///  - Ocultar / Mostrar en el menú (isAvailable): no borra nada.
///  - Editar.
///  - Eliminar: borrado definitivo de la base de datos.
class AdminProductCard extends StatelessWidget {
  final Product product;
  final bool isBusy;
  final VoidCallback onToggleAvailability;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AdminProductCard({
    super.key,
    required this.product,
    required this.isBusy,
    required this.onToggleAvailability,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardColor = theme.cardTheme.color ?? (isDark ? AppColors.darkSurface : AppColors.lightSurface);
    final textColor = theme.colorScheme.onSurface;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final fill = isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle;
    final visible = product.isAvailable;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(isDark ? 40 : 8), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Opacity(
            opacity: visible ? 1 : 0.55,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 72,
                    height: 72,
                    color: fill,
                    child: product.imageUrl.startsWith('http')
                        ? Image.network(
                            product.imageUrl,
                            fit: BoxFit.cover,
                            // Se decodifica al tamaño real del recuadro (72 px):
                            // con cientos de productos, las imágenes completas
                            // consumían mucha memoria y tiempo.
                            cacheWidth: 160,
                            errorBuilder: (_, _, _) => Icon(Icons.local_cafe_outlined, color: subtitleColor),
                          )
                        : Icon(Icons.local_cafe_outlined, color: subtitleColor),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        product.categoryName == null ? 'Sin categoría' : categoryLabel(product.categoryName),
                        style: TextStyle(fontSize: 12, color: subtitleColor),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${product.price.toStringAsFixed(0)} COP',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                      if (product.ingredients.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          product.ingredientsText,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11, color: subtitleColor),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (visible ? const Color(0xFF4CAF50) : const Color(0xFF9E9E9E)).withAlpha(isDark ? 40 : 25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    visible ? 'Visible' : 'Oculto',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: visible ? const Color(0xFF4CAF50) : const Color(0xFF9E9E9E),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 22),
          if (isBusy)
            const Padding(
              padding: EdgeInsets.all(4),
              child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            Row(
              children: [
                TextButton.icon(
                  onPressed: onToggleAvailability,
                  icon: Icon(
                    visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 18,
                    color: subtitleColor,
                  ),
                  label: Text(
                    visible ? 'Ocultar del menú' : 'Mostrar en el menú',
                    style: TextStyle(fontSize: 12, color: subtitleColor),
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Editar',
                  icon: Icon(Icons.edit_outlined, color: subtitleColor),
                  onPressed: onEdit,
                ),
                IconButton(
                  tooltip: 'Eliminar definitivamente',
                  icon: const Icon(Icons.delete_outline, color: Color(0xFFE53935)),
                  onPressed: onDelete,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
