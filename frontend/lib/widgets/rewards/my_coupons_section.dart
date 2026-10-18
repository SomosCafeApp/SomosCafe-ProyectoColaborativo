import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/coupon.dart';
import 'user_coupon_card.dart';

/// Cupones que el cliente ya canjeó (disponibles primero).
class MyCouponsSection extends StatelessWidget {
  final List<UserCoupon> coupons;
  final VoidCallback onGoRedeem;

  const MyCouponsSection({super.key, required this.coupons, required this.onGoRedeem});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    if (coupons.isEmpty) {
      // Ancho completo: sin esto la columna se ajusta a su contenido y
      // queda pegada a la izquierda dentro de la pantalla.
      return SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            Icon(Icons.confirmation_number_outlined, size: 40, color: subtitleColor),
            const SizedBox(height: 10),
            Text(
              'Todavía no has canjeado cupones.',
              textAlign: TextAlign.center,
              style: TextStyle(color: subtitleColor, fontSize: 14),
            ),
            TextButton(onPressed: onGoRedeem, child: const Text('Ver cupones para canjear')),
          ],
          ),
        ),
      );
    }

    return Column(children: [for (final coupon in coupons) UserCouponCard(coupon: coupon)]);
  }
}
