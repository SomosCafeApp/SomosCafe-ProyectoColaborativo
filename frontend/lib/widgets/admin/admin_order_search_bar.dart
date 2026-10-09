import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AdminOrderSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged onChanged;
  final VoidCallback onClear;
  final String searchQuery;

  const AdminOrderSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final inputBgColor = isDark ? AppColors.darkSurface : AppColors.lightSurfaceSubtle;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: TextStyle(fontSize: 14, color: textColor),
      decoration: InputDecoration(
        hintText: 'Buscar por pedido, cliente, correo o teléfono...',
        hintStyle: TextStyle(
          fontSize: 13,
          color: subtitleColor.withOpacity(0.6),
        ),
        prefixIcon: Icon(Icons.search, color: subtitleColor, size: 20),
        suffixIcon: searchQuery.isEmpty
            ? null
            : IconButton(
                icon: Icon(Icons.close, color: subtitleColor, size: 18),
                onPressed: onClear,
              ),
        filled: true,
        fillColor: inputBgColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}