import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Tarjeta de un cupón del catálogo de recompensas: nombre, costo en
/// puntos, descuento (pastilla amarilla) y botón de canje. Si
/// [onRedeem] es null el botón queda deshabilitado y muestra [buttonLabel]
/// (ej. "Agotado", "Ya canjeado", "Te faltan 50 pts").
class RewardCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final int points;

  /// Descuento que da el cupón, ej. "30% OFF".
  final String pill;

  /// Condiciones en una línea (compra mínima, vigencia, cupos...).
  final String details;
  final String buttonLabel;
  final bool isBusy;
  final VoidCallback? onRedeem;

  const RewardCard({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.points,
    required this.pill,
    this.details = '',
    required this.buttonLabel,
    this.isBusy = false,
    required this.onRedeem,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor)),
                    Text(subtitle, style: TextStyle(color: subtitleColor, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      '⭐ $points puntos',
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: AppColors.accentYellow, borderRadius: BorderRadius.circular(12)),
                child: Text(
                  pill,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.black87),
                ),
              ),
            ],
          ),
          if (details.isNotEmpty) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(details, style: TextStyle(color: subtitleColor, fontSize: 11)),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isBusy ? null : onRedeem,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle,
                disabledForegroundColor: subtitleColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: isBusy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(buttonLabel),
            ),
          ),
        ],
      ),
    );
  }
}
