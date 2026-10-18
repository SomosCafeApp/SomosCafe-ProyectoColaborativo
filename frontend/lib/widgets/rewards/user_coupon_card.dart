import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/coupon.dart';

import '../../animations/animations.dart';
/// Un cupón que el cliente ya canjeó: descuento, código, condiciones
/// y estado (Disponible / Usado / Vencido).
class UserCouponCard extends StatelessWidget {
  final UserCoupon coupon;

  const UserCouponCard({super.key, required this.coupon});

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Color get _statusColor {
    if (coupon.isUsable) return const Color(0xFF4CAF50);
    return coupon.status == UserCouponStatus.used ? const Color(0xFF9E9E9E) : const Color(0xFFE53935);
  }

  @override
  Widget build(BuildContext context) => SoftFadeIn(child: _buildSoft(context));

  Widget _buildSoft(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    // Un cupón disponible que ya venció según el reloj se muestra vencido.
    final statusLabel = coupon.isUsable
        ? UserCouponStatus.available.label
        : (coupon.status == UserCouponStatus.used ? UserCouponStatus.used.label : UserCouponStatus.expired.label);

    final lines = <String>[
      if (coupon.minimumPurchase > 0) 'Compra mínima \$${couponMoney(coupon.minimumPurchase)}',
      if (coupon.maximumDiscount != null) 'Descuento máx. \$${couponMoney(coupon.maximumDiscount!)}',
      if (coupon.status == UserCouponStatus.used && coupon.usedAt != null)
        'Usado el ${_fmt(coupon.usedAt!)}'
      else if (coupon.expiresAt != null)
        'Vence el ${_fmt(coupon.expiresAt!)}'
      else
        'No vence',
    ];

    return Opacity(
      opacity: coupon.isUsable ? 1 : 0.65,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: coupon.isUsable ? Border.all(color: AppColors.accentYellow, width: 1.5) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    coupon.name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: AppColors.accentYellow, borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    coupon.label,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.black87),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              coupon.description.isNotEmpty ? coupon.description : 'Descuento en cualquier producto',
              style: TextStyle(color: subtitleColor, fontSize: 12),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor.withAlpha(isDark ? 40 : 25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _statusColor),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    coupon.giftLabel ?? 'Código ${coupon.code}',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: subtitleColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(lines.join(' · '), style: TextStyle(fontSize: 11, color: subtitleColor)),
            if (coupon.isUsable) ...[
              const SizedBox(height: 8),
              const Text(
                'Aplícalo al confirmar tu pedido',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
