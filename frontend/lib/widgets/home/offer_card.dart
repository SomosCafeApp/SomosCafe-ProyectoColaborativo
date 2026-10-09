import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/promotion.dart';

/// Tarjeta "Oferta Especial del Día". Muestra la promo marcada como
/// promo del día en el panel admin (datos reales de la base de datos).
class OfferCard extends StatelessWidget {
  final PromoOfTheDay promo;
  final VoidCallback? onOrderNow;

  const OfferCard({super.key, required this.promo, this.onOrderNow});

  /// "Aplica en: Latte, Capuchino y 2 más" (máx. 2 nombres).
  String get _productsText {
    final names = promo.products.map((p) => p.name).where((n) => n.isNotEmpty).toList();
    if (names.isEmpty) return '';
    if (names.length <= 2) return 'Aplica en: ${names.join(', ')}';
    return 'Aplica en: ${names.take(2).join(', ')} y ${names.length - 2} más';
  }

  String get _deadlineText {
    final end = promo.endDate;
    if (end == null) return '';
    String two(int n) => n.toString().padLeft(2, '0');
    return 'Hasta el ${two(end.day)}/${two(end.month)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : null,
              gradient: isDark
                  ? null
                  : const LinearGradient(
                      colors: [Color(0xFFE2CBB4), Color(0xFFB8936C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceSubtle
                        : Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Oferta Especial del Día',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  promo.headline,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  [
                    promo.name,
                    if (promo.description.isNotEmpty) promo.description,
                    if (_productsText.isNotEmpty) _productsText,
                    if (_deadlineText.isNotEmpty) _deadlineText,
                  ].join('\n'),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : Colors.white.withOpacity(0.9),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: onOrderNow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? Colors.white
                        : Colors.white,
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Ordenar Ahora',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: AppColors.accentYellow,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    promo.badgeValue,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                      height: 1,
                    ),
                  ),
                  Text(
                    'OFF',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}