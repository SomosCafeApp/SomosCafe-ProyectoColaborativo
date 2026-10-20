import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/promotion.dart';

/// Tarjeta de una promoción en el panel admin. Acciones: habilitar /
/// deshabilitar (interruptor), marcar como promo del día (estrella),
/// editar y eliminar.
class AdminPromotionCard extends StatelessWidget {
  final Promotion promotion;
  final bool isBusy;
  final ValueChanged<bool> onToggleActive;
  final VoidCallback onTogglePromoOfTheDay;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AdminPromotionCard({
    super.key,
    required this.promotion,
    required this.isBusy,
    required this.onToggleActive,
    required this.onTogglePromoOfTheDay,
    required this.onEdit,
    required this.onDelete,
  });

  String _two(int n) => n.toString().padLeft(2, '0');

  String _fmt(DateTime d) => '${_two(d.day)}/${_two(d.month)}/${d.year}';

  Color get _statusColor {
    switch (promotion.status) {
      case PromotionStatus.active:
        return const Color(0xFF4CAF50);
      case PromotionStatus.disabled:
        return const Color(0xFF9E9E9E);
      case PromotionStatus.scheduled:
        return const Color(0xFF2196F3);
      case PromotionStatus.expired:
        return const Color(0xFFE53935);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardColor = theme.cardTheme.color ?? (isDark ? AppColors.darkSurface : AppColors.lightSurface);
    final textColor = theme.colorScheme.onSurface;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final fill = isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle;

    final status = promotion.status;
    final names = promotion.products.map((p) => p.name).toList();
    final shown = names.take(4).toList();
    final extra = names.length - shown.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: promotion.isPromoOfTheDay ? Border.all(color: AppColors.accentYellow, width: 2) : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(isDark ? 40 : 8), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Opacity(
        opacity: promotion.isActive ? 1 : 0.65,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (promotion.isPromoOfTheDay)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 16, color: AppColors.accentYellow),
                    const SizedBox(width: 4),
                    Text(
                      'Promo del día (visible en el home)',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
                    ),
                  ],
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(promotion.name,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                      const SizedBox(height: 2),
                      Text('Código: ${promotion.code}', style: TextStyle(fontSize: 12, color: subtitleColor)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: AppColors.accentYellow, borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    promotion.label,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.black87),
                  ),
                ),
              ],
            ),
            if (promotion.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(promotion.description, style: TextStyle(fontSize: 13, color: subtitleColor)),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor.withAlpha(isDark ? 40 : 25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(status.label,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _statusColor)),
                ),
                const SizedBox(width: 8),
                Icon(Icons.date_range_outlined, size: 14, color: subtitleColor),
                const SizedBox(width: 4),
                Expanded(
                  child: Text('${_fmt(promotion.startDate)} → ${_fmt(promotion.endDate)}',
                      style: TextStyle(fontSize: 12, color: subtitleColor)),
                ),
              ],
            ),
            if (promotion.maximumDiscount != null) ...[
              const SizedBox(height: 6),
              Text('Tope por unidad: \$${promotion.maximumDiscount!.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 12, color: subtitleColor)),
            ],
            const SizedBox(height: 10),
            if (names.isEmpty)
              Text('Sin productos asignados (no descuenta nada)',
                  style: const TextStyle(fontSize: 12, color: Color(0xFFE53935)))
            else
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final name in shown)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(12)),
                      child: Text(name, style: TextStyle(fontSize: 11, color: textColor)),
                    ),
                  if (extra > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(12)),
                      child: Text('+$extra más', style: TextStyle(fontSize: 11, color: subtitleColor)),
                    ),
                ],
              ),
            const Divider(height: 24),
            if (isBusy)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(4),
                  child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)),
                ),
              )
            else
              Row(
                children: [
                  Switch(
                    value: promotion.isActive,
                    activeThumbColor: AppColors.primary,
                    onChanged: onToggleActive,
                  ),
                  Text(promotion.isActive ? 'Habilitada' : 'Deshabilitada',
                      style: TextStyle(fontSize: 12, color: subtitleColor)),
                  const Spacer(),
                  IconButton(
                    tooltip: promotion.isPromoOfTheDay ? 'Quitar como promo del día' : 'Marcar como promo del día',
                    icon: Icon(
                      promotion.isPromoOfTheDay ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: promotion.isPromoOfTheDay ? AppColors.accentYellow : subtitleColor,
                    ),
                    onPressed: onTogglePromoOfTheDay,
                  ),
                  IconButton(
                    tooltip: 'Editar',
                    icon: Icon(Icons.edit_outlined, color: subtitleColor),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    tooltip: 'Eliminar',
                    icon: const Icon(Icons.delete_outline, color: Color(0xFFE53935)),
                    onPressed: onDelete,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
