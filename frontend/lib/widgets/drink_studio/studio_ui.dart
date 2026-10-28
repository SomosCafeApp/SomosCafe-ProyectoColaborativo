import 'package:flutter/material.dart';

import 'studio_colors.dart';

/// Piezas visuales compartidas por todos los paneles del estudio, para
/// que tarjetas, botones y etiquetas se vean como una sola familia.
class StudioUi {
  StudioUi._();

  /// Fondo de una tarjeta de opción. Elegida: tinte de marca, borde
  /// marcado y sombra suave; sin elegir: superficie neutra con borde fino.
  static BoxDecoration choice(bool dark, {required bool selected, double radius = 20}) => BoxDecoration(
        color: selected ? StudioColors.primary.withValues(alpha: dark ? 0.28 : 0.1) : StudioColors.soft(dark),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: selected ? StudioColors.primary : StudioColors.muted(dark).withValues(alpha: 0.14), width: selected ? 1.8 : 1),
        boxShadow: selected ? [BoxShadow(color: StudioColors.primary.withValues(alpha: 0.18), blurRadius: 14, offset: const Offset(0, 5))] : const [],
      );

  static TextStyle title(bool dark) => TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.2, color: StudioColors.text(dark));
  static TextStyle hint(bool dark) => TextStyle(fontSize: 12.5, height: 1.35, color: StudioColors.muted(dark));
  static TextStyle name(bool dark) => TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, letterSpacing: -0.1, color: StudioColors.text(dark));
  static const TextStyle price = TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: StudioColors.primary);
}

/// Etiqueta de sección en mayúsculas pequeñas.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.trailing});
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(text.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.1, color: StudioColors.muted(dark))),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Control de cantidad en forma de píldora: − 2 +. Con [onPlus] o
/// [onMinus] nulos el botón se ve apagado.
class QuantityPill extends StatelessWidget {
  const QuantityPill({super.key, required this.value, this.onMinus, this.onPlus, this.compact = false});
  final int value;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final size = compact ? 28.0 : 34.0;
    Widget btn(IconData icon, VoidCallback? onTap) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: size,
            height: size,
            decoration: BoxDecoration(shape: BoxShape.circle, color: onTap == null ? StudioColors.latte.withValues(alpha: 0.3) : StudioColors.primary),
            child: Icon(icon, size: compact ? 17 : 20, color: Colors.white),
          ),
        );
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: StudioColors.panel(dark),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: StudioColors.primary.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          btn(Icons.remove_rounded, onMinus),
          SizedBox(
            width: compact ? 26 : 32,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
              child: Text('$value', key: ValueKey(value), textAlign: TextAlign.center, style: TextStyle(fontSize: compact ? 14 : 16, fontWeight: FontWeight.w900, color: StudioColors.text(dark))),
            ),
          ),
          btn(Icons.add_rounded, onPlus),
        ],
      ),
    );
  }
}

/// Pestañas en píldora para cambiar de sección dentro de un panel.
class StudioTabs extends StatelessWidget {
  const StudioTabs({super.key, required this.labels, required this.index, required this.onChanged, this.badges = const {}});
  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;

  /// Cantidad elegida por pestaña, para mostrar un contador.
  final Map<int, int> badges;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: StudioColors.soft(dark), borderRadius: BorderRadius.circular(40)),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    gradient: i == index ? StudioColors.brand : null,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: i == index ? [BoxShadow(color: StudioColors.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))] : const [],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(labels[i], style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: i == index ? Colors.white : StudioColors.muted(dark))),
                      if ((badges[i] ?? 0) > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(color: i == index ? Colors.white : StudioColors.primary, borderRadius: BorderRadius.circular(10)),
                          child: Text('${badges[i]}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: i == index ? StudioColors.primary : Colors.white)),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
