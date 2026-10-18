import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/coupon.dart';

/// Tarjeta de un cupón en el panel admin. Acciones: habilitar /
/// deshabilitar (interruptor), reactivar (cuando está agotado), editar
/// y eliminar.
class AdminCouponCard extends StatelessWidget {
  final Coupon coupon;
  final bool isBusy;
  final ValueChanged<bool> onToggleActive;
  final VoidCallback onReactivate;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AdminCouponCard({
    super.key,
    required this.coupon,
    required this.isBusy,
    required this.onToggleActive,
    required this.onReactivate,
    required this.onEdit,
    required this.onDelete,
  });

  bool get _soldOut => coupon.isActive && coupon.soldOut;

  String get _statusLabel {
    if (!coupon.isActive) return 'Deshabilitado';
    return _soldOut ? 'Agotado' : 'Habilitado';
  }

  Color get _statusColor {
    if (!coupon.isActive) return const Color(0xFF9E9E9E);
    return _soldOut ? const Color(0xFFE53935) : const Color(0xFF4CAF50);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardColor = theme.cardTheme.color ?? (isDark ? AppColors.darkSurface : AppColors.lightSurface);
    final textColor = theme.colorScheme.onSurface;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final redeemed = coupon.isGift
        ? '${coupon.redeemedCount} entregados'
        : coupon.redeemLimit == null
            ? '${coupon.redeemedCount} canjeados · sin límite'
            : '${coupon.redeemedCount} de ${coupon.redeemLimit} canjeados';

    final conditions = <String>[
      if (coupon.minimumPurchase > 0) 'Compra mínima \$${couponMoney(coupon.minimumPurchase)}',
      if (coupon.maximumDiscount != null) 'Tope \$${couponMoney(coupon.maximumDiscount!)}',
      coupon.validDays == null
          ? 'No vence'
          : 'Válido ${coupon.validDays} días ${coupon.isGift ? 'desde que se entrega' : 'tras canjearlo'}',
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(isDark ? 40 : 8), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Opacity(
        opacity: coupon.isActive ? 1 : 0.65,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(coupon.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                      const SizedBox(height: 2),
                      Text(coupon.isGift ? '🎁 ${coupon.kindLabel}' : '⭐ ${coupon.pointsCost} puntos',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                    ],
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
            if (coupon.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(coupon.description, style: TextStyle(fontSize: 13, color: subtitleColor)),
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
                  child: Text(_statusLabel,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _statusColor)),
                ),
                const SizedBox(width: 8),
                Icon(Icons.confirmation_number_outlined, size: 14, color: subtitleColor),
                const SizedBox(width: 4),
                Expanded(child: Text(redeemed, style: TextStyle(fontSize: 12, color: subtitleColor))),
              ],
            ),
            const SizedBox(height: 6),
            Text(conditions.join(' · '), style: TextStyle(fontSize: 12, color: subtitleColor)),
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
                    value: coupon.isActive,
                    activeColor: AppColors.primary,
                    onChanged: onToggleActive,
                  ),
                  Text(coupon.isActive ? 'Habilitado' : 'Deshabilitado',
                      style: TextStyle(fontSize: 12, color: subtitleColor)),
                  const Spacer(),
                  if (_soldOut)
                    TextButton.icon(
                      onPressed: onReactivate,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Reactivar'),
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
