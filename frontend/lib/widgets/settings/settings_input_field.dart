import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';

/// Campo de texto con etiqueta, con el mismo estilo de los formularios
/// de login / recuperación (relleno suave, bordes redondeados). Con
/// [obscure] muestra el ojito para ver u ocultar el texto.
class SettingsInputField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final bool readOnly;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final VoidCallback? onTap;
  final String? helper;

  const SettingsInputField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    this.hint = '',
    this.obscure = false,
    this.readOnly = false,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.maxLength,
    this.onTap,
    this.helper,
  });

  @override
  State<SettingsInputField> createState() => _SettingsInputFieldState();
}

class _SettingsInputFieldState extends State<SettingsInputField> {
  late bool _hidden = widget.obscure;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final background = isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: subtitleColor)),
        const SizedBox(height: 8),
        TextField(
          controller: widget.controller,
          obscureText: _hidden,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          keyboardType: widget.keyboardType,
          textCapitalization: widget.textCapitalization,
          inputFormatters: widget.inputFormatters,
          maxLength: widget.maxLength,
          style: TextStyle(color: widget.readOnly && widget.onTap == null ? subtitleColor : textColor, fontSize: 14),
          decoration: InputDecoration(
            counterText: '',
            hintText: widget.hint,
            hintStyle: TextStyle(color: subtitleColor.withValues(alpha: 0.5), fontSize: 14),
            prefixIcon: Icon(widget.icon, color: AppColors.primary, size: 20),
            suffixIcon: widget.obscure
                ? IconButton(
                    icon: Icon(
                      _hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: subtitleColor,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _hidden = !_hidden),
                  )
                : null,
            filled: true,
            fillColor: background,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        if (widget.helper != null) ...[
          const SizedBox(height: 4),
          Text(widget.helper!, style: TextStyle(fontSize: 11, color: subtitleColor)),
        ],
      ],
    );
  }
}
