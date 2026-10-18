import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Tarjetas de categorías del Home. Al tocar una se abre el Menú con esa
/// categoría ya filtrada; por eso no guarda ninguna selección.
class CategorySelector extends StatelessWidget {
  final List<Map<String, dynamic>> categories;

  /// Recibe el 'id' de la categoría tocada.
  final ValueChanged<String> onCategorySelected;

  const CategorySelector({
    super.key,
    required this.categories,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryBrown = theme.colorScheme.primary;

    // IntrinsicHeight + stretch: las tres tarjetas miden lo mismo (ancho
    // por Expanded, alto por la más alta), aunque una etiqueta ocupe una
    // sola línea ("Postres") y las otras dos.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(categories.length, (index) {
          final cat = categories[index];

          final lightBg = cat['bgColor'] ?? AppColors.catWarm;
          final cardBgColor = isDark ? AppColors.darkSurface : lightBg;
          final iconBgColor = isDark ? AppColors.darkSurfaceSubtle : cat['iconBgColor'];
          final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

          return Expanded(
            child: GestureDetector(
              onTap: () => onCategorySelected(cat['id'] as String),
              child: Container(
                margin: EdgeInsets.only(
                  right: index < categories.length - 1 ? 12 : 0,
                ),
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: iconBgColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        cat['icon'],
                        color: cat['iconColor'] ?? primaryBrown,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      cat['label'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
