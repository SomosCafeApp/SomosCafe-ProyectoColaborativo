import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class EmptyFavoritesView extends StatelessWidget {
  final VoidCallback? onExploreMenu;

  const EmptyFavoritesView({super.key, this.onExploreMenu});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final circleBgColor = isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle;
    final iconColor = isDark ? AppColors.darkTextSecondary : AppColors.primary;

    final buttonBgColor = AppColors.primary;
    final buttonTextColor = Colors.white;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.12,
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ícono circular de favoritos
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    color: circleBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.favorite_border_rounded,
                      size: 58,
                      color: iconColor,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Título
                Text(
                  'No tienes favoritos',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 10),

                // Subtítulo
                Text(
                  'Explora nuestro menú y marca tus productos favoritos para encontrarlos fácilmente aquí.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: subtitleColor,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 28),

                // Botón Explorar Menú
                ElevatedButton(
                  onPressed: onExploreMenu ?? () => Navigator.of(context).maybePop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonBgColor,
                    elevation: isDark ? 0 : 2,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Explorar Menú',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: buttonTextColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: buttonTextColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}