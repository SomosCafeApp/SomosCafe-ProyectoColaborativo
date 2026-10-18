import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../models/coupon.dart';
import '../providers/coupons_provider.dart';
import '../providers/points_provider.dart';
import 'points_history_page.dart';
import '../widgets/common/styled_confirm_dialog.dart';
import '../widgets/rewards/coupon_catalog_section.dart';
import '../widgets/rewards/earn_points_card.dart';
import '../widgets/rewards/my_coupons_section.dart';
import '../widgets/rewards/reward_header.dart';
import '../widgets/rewards/rewards_tab_bar.dart';

import '../animations/animations.dart';
/// Recompensas: el cliente canjea sus puntos por cupones reales que
/// crea el administrador (ver backend /api/coupons) y consulta los que
/// ya tiene. Los cupones se aplican al confirmar un pedido.
class RewardsPage extends StatefulWidget {
  const RewardsPage({super.key});

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  bool _showMine = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  Future<void> _refresh() => Future.wait([
        context.read<PointsProvider>().fetchBalance(),
        context.read<CouponsProvider>().fetchAll(),
      ]);

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleRedeem(Coupon coupon) async {
    final points = context.read<PointsProvider>();
    final coupons = context.read<CouponsProvider>();

    final confirmed = await showStyledConfirmDialog(
      context,
      icon: Icons.card_giftcard_rounded,
      title: 'Canjear puntos',
      message: '¿Canjear ${coupon.pointsCost} puntos por "${coupon.name}" (${coupon.label})?',
      confirmLabel: 'Canjear',
      destructive: false,
    );
    if (!confirmed || !mounted) return;

    final result = await coupons.redeem(coupon);
    if (!mounted) return;

    if (result == null) {
      _snack(coupons.errorMessage ?? 'No se pudo canjear el cupón');
      return;
    }

    points.setBalance(result.balance);
    setState(() => _showMine = true);
    _snack('¡Canjeaste "${coupon.name}"! Úsalo al confirmar tu pedido.');
  }

  /// Próximo cupón al que apunta el usuario: el más barato que aún no
  /// puede pagar (o el más caro si ya alcanza para todos).
  Coupon? _nextCoupon(List<Coupon> catalog, int balance) {
    final redeemable = catalog.where((c) => c.isRedeemable).toList()
      ..sort((a, b) => a.pointsCost.compareTo(b.pointsCost));
    if (redeemable.isEmpty) return null;
    return redeemable.firstWhere((c) => c.pointsCost > balance, orElse: () => redeemable.last);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    final balance = context.watch<PointsProvider>().balance;
    final coupons = context.watch<CouponsProvider>();

    final next = _nextCoupon(coupons.catalog, balance);
    final progress = next == null || next.pointsCost <= 0 ? 0.0 : (balance / next.pointsCost).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RewardHeader(points: balance, nextRewardPoints: next?.pointsCost, progress: progress),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PointsHistoryPage()),
                        ),
                        icon: const Icon(Icons.history_rounded, size: 18),
                        label: const Text('Historial de puntos'),
                      ),
                    ),
                    RewardsTabBar(
                      showMine: _showMine,
                      availableCount: coupons.available.length,
                      onChanged: (value) => setState(() => _showMine = value),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _showMine ? 'Mis cupones' : 'Disponibles para Ti',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    const SizedBox(height: 12),
                    if (coupons.isLoading && coupons.catalog.isEmpty && coupons.mine.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CoffeeCupLoader()),
                      )
                    else if (_showMine)
                      MyCouponsSection(coupons: coupons.mine, onGoRedeem: () => setState(() => _showMine = false))
                    else
                      CouponCatalogSection(
                        coupons: coupons.catalog,
                        balance: balance,
                        redeemingId: coupons.redeemingId,
                        onRedeem: _handleRedeem,
                      ),
                    const SizedBox(height: 20),
                    EarnPointsCard(balance: balance),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
