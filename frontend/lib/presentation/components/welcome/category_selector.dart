import 'package:flutter/material.dart';

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
    final primaryBrown = Theme.of(context).colorScheme.primary;

    return Row(
      children: List.generate(categories.length, (index) {
        final cat = categories[index];
        final isSelected = selectedIndex == index;

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
                color: cat['bgColor'],
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
                      color: cat['iconBgColor'],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(cat['icon'], color: cat['iconColor'], size: 24),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    cat['label'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.bold,
                      color: Colors.black87,
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