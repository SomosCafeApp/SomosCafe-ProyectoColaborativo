import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CategorySelector extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final int selectedIndex;
  final ValueChanged<int> onCategorySelected;

  const CategorySelector({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryBrown = theme.colorScheme.primary;

    return Row(
      children: List.generate(categories.length, (index) {
        final cat = categories[index];
        final isSelected = selectedIndex == index;

        final lightBg = cat['bgColor'] ?? AppColors.catWarm;
        final cardBgColor = isDark ? AppColors.darkSurface : lightBg;
        final iconBgColor = isDark ? AppColors.darkSurfaceSubtle : cat['iconBgColor'];
        final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

        return Expanded(
          child: GestureDetector(
            onTap: () => onCategorySelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                right: index < categories.length - 1 ? 12 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? primaryBrown : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      cat['icon'],
                      color: cat['iconColor'] ?? primaryBrown,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    cat['label'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.bold,
                      color: textColor,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}