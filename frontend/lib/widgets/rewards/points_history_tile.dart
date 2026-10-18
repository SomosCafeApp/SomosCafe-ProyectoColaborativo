import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/points_model.dart';

import '../../animations/animations.dart';
/// Un movimiento del historial: compra, canje de cupón, bono o ajuste.
class PointsHistoryTile extends StatelessWidget {
  final PointHistoryEntry entry;

  const PointsHistoryTile({super.key, required this.entry});

  IconData get _icon {
    switch (entry.type) {
      case 'purchase':
        return Icons.shopping_bag_outlined;
      case 'redeemed':
        return Icons.card_giftcard_rounded;
      case 'bonus':
        return Icons.star_rounded;
      default:
        return Icons.tune_rounded;
    }
  }

  String get _fallbackTitle {
    switch (entry.type) {
      case 'purchase':
        return 'Compra';
      case 'redeemed':
        return 'Canje de cupón';
      case 'bonus':
        return 'Bono';
      default:
        return 'Ajuste de puntos';
    }
  }

  String _date(DateTime d) {
    final local = d.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(local.day)}/${two(local.month)}/${local.year} · ${two(local.hour)}:${two(local.minute)}';
  }

  @override
  Widget build(BuildContext context) => SoftFadeIn(child: _buildSoft(context));

  Widget _buildSoft(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final positive = entry.amount >= 0;
    final amountColor = positive ? const Color(0xFF4CAF50) : const Color(0xFFE57373);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(isDark ? 30 : 8), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.description.isNotEmpty ? entry.description : _fallbackTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textColor),
                ),
                if (entry.createdAt != null)
                  Text(_date(entry.createdAt!), style: TextStyle(fontSize: 11, color: subtitleColor)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${positive ? '+' : ''}${entry.amount}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: amountColor),
          ),
        ],
      ),
    );
  }
}
