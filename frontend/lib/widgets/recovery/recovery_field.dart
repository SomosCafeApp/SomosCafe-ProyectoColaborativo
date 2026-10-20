import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import 'recovery_style.dart';

/// Etiqueta + campo de texto con el estilo de recuperar contraseña.
///
/// - [onToggleObscure] != null muestra el ojo para ver/ocultar el texto.
/// - [centered] centra el texto con espaciado (campo del código).
class RecoveryField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscure;
  final VoidCallback? onToggleObscure;
  final bool centered;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;

  const RecoveryField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.keyboardType,
    this.obscure = false,
    this.onToggleObscure,
    this.centered = false,
    this.maxLength,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final codeStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 6,
      color: textColor,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: subtitleColor,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscure,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          textAlign: centered ? TextAlign.center : TextAlign.start,
          style: centered ? codeStyle : TextStyle(color: textColor, fontSize: 14),
          decoration: recoveryInputDecoration(
            context,
            hint: hint,
            icon: icon,
            hintStyle: centered ? codeStyle : null,
            suffix: onToggleObscure == null
                ? null
                : GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onToggleObscure,
                    child: Icon(
                      obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: subtitleColor,
                      size: 20,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
