import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ProfileSubPageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onBackPressed;

  const ProfileSubPageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final primaryBrown = AppColors.primary;

    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 20, left: 16, right: 16),
      color: primaryBrown,
      width: double.infinity,
      child: Row(
        children: [
          // Botón de retroceso dentro de una burbuja translúcida
          GestureDetector(
            onTap: onBackPressed ?? () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51), 
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Textos del Header
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withAlpha(204), // 0.8 opacity equivalente
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}