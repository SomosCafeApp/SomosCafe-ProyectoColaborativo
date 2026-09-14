import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../widgets/rewards/reward_card.dart';
import '../widgets/rewards/reward_header.dart';

class RewardsPage extends StatelessWidget {
  const RewardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;

    final subtitleColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;

    final subtleSurfaceColor = isDark
        ? AppColors.darkSurfaceSubtle
        : AppColors.lightSurfaceSubtle;

    final pointsSectionBackground = isDark
        ? AppColors.darkSurfaceSubtle
        : const Color(0xFFFFFDE7);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const RewardHeader(
                points: 450,
                nextRewardPoints: 100,
                progress: 0.75,
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      context,
                      Icons.auto_awesome,
                      'Disponibles para Ti',
                    ),

                    const SizedBox(height: 12),

                    RewardCard(
                      icon: Icons.percent,
                      iconBg: isDark
                          ? AppColors.darkSurfaceSubtle
                          : const Color(0xFFE8F5E9),
                      iconColor: isDark
                          ? AppColors.primary
                          : Colors.green,
                      title: '30% de Descuento',
                      subtitle: 'En tu próxima compra',
                      points: 200,
                      expiry: '3 días',
                      onRedeem: () {},
                    ),

                    const SizedBox(height: 12),

                    RewardCard(
                      icon: Icons.card_giftcard,
                      iconBg: isDark
                          ? AppColors.darkSurfaceSubtle
                          : const Color(0xFFFCE4EC),
                      iconColor: isDark
                          ? AppColors.primary
                          : Colors.pink,
                      title: '2x1 en Postres',
                      subtitle: 'Compra uno y lleva otro gratis',
                      points: 350,
                      expiry: '7 días',
                      onRedeem: () {},
                    ),

                    const SizedBox(height: 20),

                    _buildSectionHeader(
                      context,
                      Icons.bookmark_outline,
                      'Sigue Acumulando',
                    ),

                    const SizedBox(height: 12),

                    Card(
                      elevation: 0,
                      color: surfaceColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: subtleSurfaceColor,
                          child: Icon(
                            Icons.local_cafe_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                        title: Text(
                          'Café Gratis',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        subtitle: Text(
                          'Cualquier café de tamaño medio\n⭐ 50 puntos más',
                          style: TextStyle(
                            color: subtitleColor,
                          ),
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
                          _buildSectionHeader(
                            context,
                            Icons.auto_awesome,
                            'Cómo Ganar Puntos',
                            color: AppColors.primary,
                          ),

                          const SizedBox(height: 12),

                          _buildInstruction(
                            context,
                            Icons.local_cafe,
                            '10 puntos',
                            'por cada compra',
                          ),

                          _buildInstruction(
                            context,
                            Icons.star_outline,
                            '50 puntos',
                            'por cada reseña',
                          ),

                          _buildInstruction(
                            context,
                            Icons.card_giftcard,
                            '100 puntos',
                            'por referir amigos',
                          ),
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

  Widget _buildSectionHeader(
    BuildContext context,
    IconData icon,
    String title, {
    Color? color,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;

    return Row(
      children: [
        Icon(
          icon,
          color: color ?? AppColors.primary,
          size: 18,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstruction(
    BuildContext context,
    IconData icon,
    String boldText,
    String normalText,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;

    final subtitleColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    final iconBackground = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: iconBackground,
            child: Icon(
              icon,
              size: 16,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            boldText,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              normalText,
              style: TextStyle(
                color: subtitleColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}