import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../animations/press_scale.dart';
import '../../providers/drink_studio_provider.dart';
import 'studio_colors.dart';

/// Invitación a retomar la última personalización de esta bebida.
class LastRecipeBanner extends StatelessWidget {
  const LastRecipeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<DrinkStudioProvider>();
    final recipe = s.lastRecipe;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedSize(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      child: recipe == null
          ? const SizedBox(width: double.infinity)
          : Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              padding: const EdgeInsets.fromLTRB(14, 8, 6, 8),
              decoration: BoxDecoration(
                color: StudioColors.primary.withValues(alpha: dark ? 0.28 : 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: StudioColors.primary.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.history_rounded, size: 20, color: StudioColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      recipe.customization.summaryLines.isEmpty ? 'Retomar tu última bebida' : 'Tu última: ${recipe.customization.summaryLines.join(' · ')}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: StudioColors.text(dark)),
                    ),
                  ),
                  PressScale(
                    onTap: () => s.applyRecipe(recipe),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: StudioColors.primary, borderRadius: BorderRadius.circular(12)),
                      child: const Text('Usar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12.5)),
                    ),
                  ),
                  IconButton(tooltip: 'Descartar', visualDensity: VisualDensity.compact, onPressed: s.dismissLastRecipe, icon: Icon(Icons.close_rounded, size: 18, color: StudioColors.muted(dark))),
                ],
              ),
            ),
    );
  }
}
