import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/utils/money_format.dart';
import '../../models/product_model.dart';
import '../../providers/drink_studio_provider.dart';
import 'option_card.dart';
import 'studio_colors.dart';

/// Acompañamientos: los postres reales del menú, con su foto, precio
/// vigente (con promoción si la hay) y disponibilidad.
class PairingPanel extends StatelessWidget {
  const PairingPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<DrinkStudioProvider>();
    final items = s.availablePairings;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return StagePanel(
      title: '¿Algo para acompañar?',
      hint: s.pairings.isEmpty
          ? 'Opcional. Se agregan al carrito como productos aparte.'
          : '${s.pairings.length} elegido${s.pairings.length == 1 ? '' : 's'} · ${formatCop(s.pairingsTotal)}',
      child: SizedBox(
        height: 176,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (context, i) => _PairingCard(
            product: items[i],
            dark: dark,
            selected: s.pairings.containsKey(items[i].id),
            onTap: () {
              HapticFeedback.selectionClick();
              s.togglePairing(items[i]);
            },
          ),
        ),
      ),
    );
  }
}

class _PairingCard extends StatelessWidget {
  const _PairingCard({required this.product, required this.selected, required this.onTap, required this.dark});
  final Product product;
  final bool selected;
  final bool dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final url = product.imageUrl;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: selected ? 1.03 : 1,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: 140,
          decoration: BoxDecoration(
            color: StudioColors.soft(dark),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selected ? StudioColors.primary : Colors.transparent, width: 2),
            boxShadow: selected ? [BoxShadow(color: StudioColors.primary.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))] : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              fit: StackFit.expand,
              children: [
                url.startsWith('http')
                    ? Image.network(url, fit: BoxFit.cover, errorBuilder: (_, _, _) => const _Fallback())
                    : const _Fallback(),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.center, end: Alignment.bottomCenter, colors: [Colors.transparent, Color(0xCC2A1A10)]),
                  ),
                ),
                Positioned(
                  left: 10,
                  right: 10,
                  bottom: 8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w800, height: 1.15)),
                      const SizedBox(height: 2),
                      Text(formatCop(product.effectivePrice), style: const TextStyle(color: Color(0xFFFFE2B0), fontSize: 12.5, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                    child: Container(
                      key: ValueKey(selected),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: selected ? StudioColors.primary : Colors.white.withValues(alpha: 0.85)),
                      child: Icon(selected ? Icons.check_rounded : Icons.add_rounded, size: 18, color: selected ? Colors.white : StudioColors.primary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback();

  @override
  Widget build(BuildContext context) => Container(
        color: StudioColors.beige,
        child: const Center(child: Icon(Icons.cake_rounded, color: StudioColors.latte, size: 38)),
      );
}
