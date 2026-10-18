import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/coupon.dart';
import '../../providers/coupons_provider.dart';
import 'confirm_section_title.dart';

/// Resultado de la hoja de cupones: distingue "quitar el cupón" (coupon
/// null) de cerrar la hoja sin elegir nada (la hoja devuelve null).
class _CouponPick {
  final UserCoupon? coupon;
  const _CouponPick(this.coupon);
}

/// Sección "Cupón de recompensas" de la confirmación del pedido: aplica
/// uno de los cupones que el cliente ya canjeó. El descuento es sobre los
/// productos (con promociones) y no sobre el envío; el backend lo
/// recalcula y valida al crear el pedido.
class CouponPickerSection extends StatefulWidget {
  final UserCoupon? selected;

  /// Total de productos ya con promociones (base del cupón).
  final double merchandiseTotal;
  final ValueChanged<UserCoupon?> onChanged;

  const CouponPickerSection({
    super.key,
    required this.selected,
    required this.merchandiseTotal,
    required this.onChanged,
  });

  @override
  State<CouponPickerSection> createState() => _CouponPickerSectionState();
}

class _CouponPickerSectionState extends State<CouponPickerSection> {
  @override
  void initState() {
    super.initState();
    // Cupones al día (pudieron vencer o devolverse al cancelar un pedido).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<CouponsProvider>().fetchMine();
    });
  }

  Future<void> _open(List<UserCoupon> coupons) async {
    final pick = await showModalBottomSheet<_CouponPick>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _CouponSheet(
        coupons: coupons,
        selectedId: widget.selected?.id,
        merchandiseTotal: widget.merchandiseTotal,
      ),
    );
    if (pick != null) widget.onChanged(pick.coupon);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final available = context.watch<CouponsProvider>().available;
    final selected = widget.selected;
    final discount = selected?.discountFor(widget.merchandiseTotal) ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ConfirmSectionTitle('Cupón de recompensas'),
        if (available.isEmpty && selected == null)
          Text(
            'No tienes cupones disponibles. Canjea tus puntos en Recompensas.',
            style: TextStyle(fontSize: 13, color: subtitleColor),
          )
        else
          InkWell(
            onTap: () => _open(available),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected != null ? AppColors.primary : (isDark ? Colors.white24 : Colors.grey.shade300),
                  width: selected != null ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.confirmation_number_outlined, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selected != null ? 'Cupón aplicado' : 'Aplicar un cupón',
                          style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                        ),
                        Text(
                          selected != null
                              ? '${selected.label} · ahorras \$${couponMoney(discount)}'
                              : '${available.length} disponible${available.length == 1 ? '' : 's'}',
                          style: TextStyle(fontSize: 12, color: subtitleColor),
                        ),
                      ],
                    ),
                  ),
                  if (selected != null)
                    GestureDetector(
                      onTap: () => widget.onChanged(null),
                      child: Icon(Icons.close_rounded, color: subtitleColor),
                    )
                  else
                    Icon(Icons.chevron_right_rounded, color: subtitleColor),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _CouponSheet extends StatelessWidget {
  final List<UserCoupon> coupons;
  final String? selectedId;
  final double merchandiseTotal;

  const _CouponSheet({required this.coupons, required this.selectedId, required this.merchandiseTotal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tus cupones',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
            const SizedBox(height: 12),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final coupon in coupons) _row(context, coupon, subtitleColor, isDark),
                ],
              ),
            ),
            if (selectedId != null)
              TextButton(
                onPressed: () => Navigator.pop(context, const _CouponPick(null)),
                child: const Text('Quitar cupón'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, UserCoupon coupon, Color subtitleColor, bool isDark) {
    final applicable = coupon.isApplicableTo(merchandiseTotal);
    final selected = coupon.id == selectedId;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: applicable ? () => Navigator.pop(context, _CouponPick(coupon)) : null,
        borderRadius: BorderRadius.circular(16),
        child: Opacity(
          opacity: applicable ? 1 : 0.55,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? AppColors.primary : (isDark ? Colors.white24 : Colors.grey.shade300),
                width: selected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: AppColors.primary, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(coupon.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                      Text(
                        applicable
                            ? 'Ahorras \$${couponMoney(coupon.discountFor(merchandiseTotal))}'
                            : 'Compra mínima \$${couponMoney(coupon.minimumPurchase)}',
                        style: TextStyle(fontSize: 12, color: subtitleColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  coupon.label,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.primary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
