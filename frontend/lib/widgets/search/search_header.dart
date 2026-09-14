import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class SearchHeader extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const SearchHeader({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Header café/moca consistente con MenuPage
    final headerBgColor = AppColors.primary;
    final headerTitleColor = Colors.white;

    // Campo de texto según las capturas de Figma
    final searchFieldBg = isDark ? const Color(0xFF281C16) : Colors.white;
    final searchTextColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final searchHintColor = isDark ? AppColors.darkTextSecondary.withOpacity(0.6) : Colors.grey.shade500;

    return Container(
      color: headerBgColor,
      padding: const EdgeInsets.only(top: 55, bottom: 20, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Buscar',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: headerTitleColor,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            onChanged: onChanged,
            style: TextStyle(color: searchTextColor, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Buscar café, postre...',
              hintStyle: TextStyle(color: searchHintColor, fontSize: 14),
              prefixIcon: Icon(Icons.search, color: searchHintColor, size: 20),
              suffixIcon: controller.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.cancel_rounded, color: searchHintColor, size: 18),
                      onPressed: onClear,
                    )
                  : null,
              filled: true,
              fillColor: searchFieldBg,
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}