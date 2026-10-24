import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/money_format.dart';
import '../../models/drink_recipe.dart';

/// Tarjeta de una receta (reciente o guardada) con sus acciones.
class RecipeCard extends StatelessWidget {
  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onPrepare,
    required this.onToggleSaved,
    required this.onDelete,
    this.onRename,
  });

  final DrinkRecipe recipe;
  final VoidCallback onPrepare;
  final VoidCallback onToggleSaved;
  final VoidCallback onDelete;
  final VoidCallback? onRename;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final subtitle = dark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final lines = recipe.customization.summaryLines;
    final image = recipe.productImage;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: recipe.isSaved ? 0.45 : 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: image != null && image.startsWith('http')
                      ? Image.network(image, fit: BoxFit.cover, errorBuilder: (_, _, _) => const _ImageFallback())
                      : const _ImageFallback(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(recipe.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface)),
                    if (recipe.name.isNotEmpty && recipe.productName != null)
                      Text(recipe.productName!, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: subtitle)),
                    const SizedBox(height: 4),
                    Text(
                      lines.isEmpty ? 'Sin personalización' : lines.join('\n'),
                      style: TextStyle(fontSize: 12, height: 1.3, color: subtitle),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(formatCop(recipe.totalPrice), style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (!recipe.available)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFE53935).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                  child: const Text('No disponible', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFFE53935))),
                ),
              const Spacer(),
              IconButton(
                tooltip: recipe.isSaved ? 'Quitar de guardadas' : 'Guardar receta',
                onPressed: onToggleSaved,
                icon: Icon(recipe.isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, color: AppColors.primary),
              ),
              if (onRename != null)
                IconButton(tooltip: 'Renombrar', onPressed: onRename, icon: const Icon(Icons.edit_outlined, color: AppColors.primary)),
              IconButton(tooltip: 'Eliminar', onPressed: onDelete, icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFE53935))),
              const SizedBox(width: 4),
              FilledButton.icon(
                onPressed: recipe.available ? onPrepare : null,
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                icon: const Icon(Icons.brush_rounded, size: 18),
                label: const Text('Preparar', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) => Container(
        color: AppColors.catWarm,
        child: const Icon(Icons.local_cafe_rounded, color: AppColors.primary),
      );
}
