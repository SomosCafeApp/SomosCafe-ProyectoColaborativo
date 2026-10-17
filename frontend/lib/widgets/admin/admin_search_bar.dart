import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Barra de búsqueda del panel admin (la misma de Pedidos y Productos).
///
/// [onChanged] se dispara con un pequeño retraso ([debounce]) para no
/// refiltrar listas grandes en cada tecla; al limpiar es inmediato.
class AdminSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final Duration debounce;

  const AdminSearchBar({
    super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.debounce = const Duration(milliseconds: 300),
  });

  @override
  State<AdminSearchBar> createState() => _AdminSearchBarState();
}

class _AdminSearchBarState extends State<AdminSearchBar> {
  Timer? _timer;

  void _handleChanged(String value) {
    _timer?.cancel();
    _timer = Timer(widget.debounce, () => widget.onChanged(value));
  }

  void _clear() {
    _timer?.cancel();
    widget.controller.clear();
    widget.onChanged('');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final inputBgColor = isDark ? AppColors.darkSurface : AppColors.lightSurfaceSubtle;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: widget.controller,
      builder: (context, value, _) => TextField(
        controller: widget.controller,
        onChanged: _handleChanged,
        textInputAction: TextInputAction.search,
        style: TextStyle(fontSize: 14, color: textColor),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: TextStyle(fontSize: 13, color: subtitleColor.withAlpha(153)),
          prefixIcon: Icon(Icons.search, color: subtitleColor, size: 20),
          suffixIcon: value.text.isEmpty
              ? null
              : IconButton(
                  icon: Icon(Icons.close, color: subtitleColor, size: 18),
                  onPressed: _clear,
                ),
          filled: true,
          fillColor: inputBgColor,
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
