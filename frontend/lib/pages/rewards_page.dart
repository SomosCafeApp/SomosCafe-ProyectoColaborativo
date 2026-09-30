import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../providers/points_provider.dart';
import '../widgets/rewards/reward_card.dart';
import '../widgets/rewards/reward_header.dart';

/// Recompensa canjeable. El backend no tiene un catálogo de premios
/// (solo un saldo de puntos + POST /points/redeem con monto libre),
/// así que el catálogo vive aquí; el canje sí es 100% real.
class _RewardOption {
  final IconData icon;
  final String title;
  final String subtitle;
  final int cost;

  const _RewardOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.cost,
  });
}

const _rewardCatalog = [
  _RewardOption(
    icon: Icons.percent,
    title: '30% de Descuento',
    subtitle: 'En tu próxima compra',
    cost: 200,
  ),
  _RewardOption(
    icon: Icons.card_giftcard,
    title: '2x1 en Postres',
    subtitle: 'Compra uno y lleva otro gratis',
    cost: 350,
  ),
  _RewardOption(
    icon: Icons.local_cafe_outlined,
    title: 'Café Gratis',
    subtitle: 'Cualquier café de tamaño medio',
    cost: 500,
  ),
];

class RewardsPage extends StatefulWidget {
  const RewardsPage({super.key});

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PointsProvider>().fetchBalance();
    });
  }

  Future<void> _handleRedeem(_RewardOption reward) async {
    final pointsProvider = context.read<PointsProvider>();

    if (pointsProvider.balance < reward.cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No tienes suficientes puntos para este premio')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Canjear puntos'),
        content: Text('¿Canjear ${reward.cost} puntos por "${reward.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Canjear')),
        ],
      ),
    );
    if (confirmed != true) return;

    final success = await pointsProvider.redeemPoints(amount: reward.cost, description: reward.title);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? '¡Canjeaste "${reward.title}"!' : (pointsProvider.errorMessage ?? 'No se pudo canjear')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final subtleSurfaceColor = isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle;
    final pointsSectionBackground = isDark ? AppColors.darkSurfaceSubtle : const Color(0xFFFFFDE7);

    final pointsProvider = context.watch<PointsProvider>();
    final balance = pointsProvider.balance;

    // Próxima recompensa: la más barata que el usuario todavía no
    // puede pagar (o la más cara del catálogo si ya las tiene todas).
    final nextReward = _rewardCatalog.firstWhere(
      (r) => r.cost > balance,
      orElse: () => _rewardCatalog.last,
    );
    final progress = nextReward.cost > 0 ? (balance / nextReward.cost).clamp(0.0, 1.0) : 1.0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: pointsProvider.fetchBalance,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RewardHeader(
                points: balance,
                nextRewardPoints: nextReward.cost,
                progress: progress,
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(context, Icons.auto_awesome, 'Disponibles para Ti'),
                    const SizedBox(height: 12),
                    if (pointsProvider.isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else
                      ..._rewardCatalog.map((reward) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: RewardCard(
                              icon: reward.icon,
                              iconBg: isDark ? AppColors.darkSurfaceSubtle : const Color(0xFFE8F5E9),
                              iconColor: isDark ? AppColors.primary : Colors.green,
                              title: reward.title,
                              subtitle: reward.subtitle,
                              points: reward.cost,
                              expiry: balance >= reward.cost ? 'Disponible' : 'Te faltan ${reward.cost - balance}',
                              onRedeem: () => _handleRedeem(reward),
                            ),
                          )),
                    const SizedBox(height: 8),
                    _buildSectionHeader(context, Icons.bookmark_outline, 'Sigue Acumulando'),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 0,
                      color: surfaceColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: subtleSurfaceColor,
                          child: Icon(Icons.stars_rounded, color: AppColors.primary),
                        ),
                        title: Text(
                          'Tienes $balance puntos',
                          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                        ),
                        subtitle: Text(
                          'Sigue comprando y dejando reseñas para ganar más',
                          style: TextStyle(color: subtitleColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: pointsSectionBackground,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(context, Icons.auto_awesome, 'Cómo Ganar Puntos', color: AppColors.primary),
                          const SizedBox(height: 12),
                          _buildInstruction(context, Icons.local_cafe, '10 puntos', 'por cada compra'),
                          _buildInstruction(context, Icons.star_outline, '50 puntos', 'por cada reseña'),
                          _buildInstruction(context, Icons.card_giftcard, '100 puntos', 'por referir amigos'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, IconData icon, String title, {Color? color}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Row(
      children: [
        Icon(icon, color: color ?? AppColors.primary, size: 18),
        const SizedBox(width: 6),
        Expanded(
          child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
        ),
      ],
    );
  }

  Widget _buildInstruction(BuildContext context, IconData icon, String boldText, String normalText) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final iconBackground = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: iconBackground,
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Text(boldText, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(width: 4),
          Expanded(child: Text(normalText, style: TextStyle(color: subtitleColor))),
        ],
      ),
    );
  }
}
