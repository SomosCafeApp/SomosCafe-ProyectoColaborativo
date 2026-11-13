import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../documents/document_viewer_page.dart';
import '../../documents/documents_registry.dart';

/// Texto con dos enlaces tocables: "Términos y Condiciones" y "Política
/// de Privacidad" (abren el documento correspondiente).
class TermsLinksText extends StatefulWidget {
  /// Texto antes del primer enlace, p. ej. "Al continuar aceptas los ".
  final String prefix;

  /// Texto después del segundo enlace (puede ir vacío).
  final String suffix;
  final double fontSize;
  final TextAlign textAlign;

  const TermsLinksText({
    super.key,
    required this.prefix,
    this.suffix = '',
    this.fontSize = 12,
    this.textAlign = TextAlign.start,
  });

  @override
  State<TermsLinksText> createState() => _TermsLinksTextState();
}

class _TermsLinksTextState extends State<TermsLinksText> {
  late final TapGestureRecognizer _terms;
  late final TapGestureRecognizer _privacy;

  @override
  void initState() {
    super.initState();
    _terms = TapGestureRecognizer()
      ..onTap = () => openDocument(context, termsDocument);
    _privacy = TapGestureRecognizer()
      ..onTap = () => openDocument(context, privacyDocument);
  }

  @override
  void dispose() {
    _terms.dispose();
    _privacy.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final linkColor = isDark ? AppColors.darkAccent : AppColors.primary;

    final base = TextStyle(fontSize: widget.fontSize, height: 1.4, color: muted);
    final link = base.copyWith(
      color: linkColor,
      fontWeight: FontWeight.w700,
      decoration: TextDecoration.underline,
    );

    return Text.rich(
      TextSpan(
        style: base,
        children: [
          TextSpan(text: widget.prefix),
          TextSpan(
            text: 'Términos y Condiciones',
            style: link,
            recognizer: _terms,
          ),
          const TextSpan(text: ' y la '),
          TextSpan(
            text: 'Política de Privacidad',
            style: link,
            recognizer: _privacy,
          ),
          TextSpan(text: widget.suffix),
        ],
      ),
      textAlign: widget.textAlign,
    );
  }
}

/// Casilla obligatoria de aceptación (registro).
class TermsAcceptanceRow extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const TermsAcceptanceRow({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: 'Aceptar términos y condiciones y política de privacidad',
          child: SizedBox(
            width: 28,
            height: 28,
            child: Checkbox(
              value: value,
              activeColor: AppColors.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: (v) => onChanged(v ?? false),
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 4),
            child: TermsLinksText(
              prefix: 'He leído y acepto los ',
              suffix: ', y autorizo el tratamiento de mis datos personales.',
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
