import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Opción seleccionable de la app (tipo de cupón, tipo de descuento,
/// filtros…). Un solo diseño para TODAS: seleccionada = color de marca
/// con una sombra suave; sin seleccionar = fondo tonal con texto legible
/// y una línea fina del mismo tono (nunca un borde blanco).
class AppChoiceChip extends StatelessWidget {
  const AppChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
    this.expand = false,
  });

  final String label;
  final bool selected;

  /// null = deshabilitado (la opción seleccionada conserva su color).
  final VoidCallback? onSelected;
  final IconData? icon;

  /// Ocupa todo el ancho disponible (para filas de 2-3 opciones).
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final enabled = onSelected != null;

    final idleBg = dark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle;
    final idleLine = dark ? AppColors.darkBorder : const Color(0xFFE7DED3);
    final idleText = dark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final fg = selected ? Colors.white : idleText;

    final chip = AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : idleBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: selected ? AppColors.primary : idleLine, width: 1),
        boxShadow: selected
            ? [BoxShadow(color: AppColors.primary.withValues(alpha: dark ? 0.35 : 0.28), blurRadius: 10, offset: const Offset(0, 4))]
            : const [],
      ),
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 17, color: fg),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              style: TextStyle(fontSize: 13, fontWeight: selected ? FontWeight.w800 : FontWeight.w600, color: fg),
              child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
            ),
          ),
        ],
      ),
    );

    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      label: label,
      child: Opacity(
        opacity: enabled || selected ? 1 : 0.55,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: enabled ? onSelected : null,
            child: chip,
          ),
        ),
      ),
    );
  }
}
