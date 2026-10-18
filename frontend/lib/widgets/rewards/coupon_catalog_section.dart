import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/coupon.dart';
import '../../models/promotion.dart';
import 'reward_card.dart';

/// Lista de cupones canjeables. Cada tarjeta muestra el estado real:
/// canjear, "Te faltan X pts", "Ya canjeado" o "Agotado".
class CouponCatalogSection extends StatelessWidget {
  final List<Coupon> coupons;
  final int balance;
  final String? redeemingId;
  final ValueChanged<Coupon> onRedeem;

  const CouponCatalogSection({
    super.key,
    required this.coupons,
    required this.balance,
    required this.redeemingId,
    required this.onRedeem,
  });

  String _details(Coupon c) {
    final parts = <String>[
      if (c.minimumPurchase > 0) 'Compra mínima \$${couponMoney(c.minimumPurchase)}',
      if (c.maximumDiscount != null) 'Descuento máx. \$${couponMoney(c.maximumDiscount!)}',
      c.validDays == null ? 'No vence' : 'Válido ${c.validDays} día${c.validDays == 1 ? '' : 's'} tras canjearlo',
      if (c.remaining != null && !c.soldOut) 'Quedan ${c.remaining}',
    ];
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    if (coupons.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: Center(
          child: Text(
            'Pronto habrá cupones para canjear.',
            style: TextStyle(color: subtitleColor, fontSize: 14),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (final coupon in coupons)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _card(coupon, isDark),
          ),
      ],
    );
  }

  Widget _card(Coupon coupon, bool isDark) {
    final missing = coupon.pointsCost - balance;

    String buttonLabel = 'Canjear Ahora';
    VoidCallback? onTap = () => onRedeem(coupon);

    if (coupon.alreadyRedeemed) {
      buttonLabel = 'Ya canjeado';
      onTap = null;
    } else if (coupon.soldOut) {
      buttonLabel = 'Agotado';
      onTap = null;
    } else if (missing > 0) {
      buttonLabel = 'Te faltan $missing puntos';
      onTap = null;
    }

    return RewardCard(
      icon: coupon.discountType == PromotionDiscountType.percentage ? Icons.percent : Icons.local_offer_outlined,
      iconBg: isDark ? AppColors.darkSurfaceSubtle : const Color(0xFFE8F5E9),
      iconColor: isDark ? AppColors.primary : Colors.green,
      title: coupon.name,
      subtitle: coupon.description.isNotEmpty ? coupon.description : 'Descuento en cualquier producto',
      points: coupon.pointsCost,
      pill: coupon.label,
      details: _details(coupon),
      buttonLabel: buttonLabel,
      isBusy: redeemingId == coupon.id,
      onRedeem: onTap,
    );
  }
}
