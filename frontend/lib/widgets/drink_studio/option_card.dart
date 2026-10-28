import 'package:flutter/material.dart';

import '../../animations/press_scale.dart';
import 'studio_colors.dart';
import 'studio_ui.dart';

/// Tarjeta táctil de una opción (tamaño, leche, jarabe...). Se anima al
/// elegirla y muestra su precio real.
class OptionCard extends StatelessWidget {
  const OptionCard({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.caption,
    this.leading,
    this.width,
  });

  final String label;
  final String? caption;
  final bool selected;
  final VoidCallback onTap;
  final Widget? leading;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final text = StudioColors.text(dark);
    return PressScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: StudioUi.choice(dark, selected: selected, radius: 18),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 8)],
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: text)),
                  if (caption != null)
                    Text(caption!, style: TextStyle(fontSize: 11, color: StudioColors.muted(dark))),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: selected
                  ? const Padding(
                      key: ValueKey('on'),
                      padding: EdgeInsets.only(left: 6),
                      child: Icon(Icons.check_circle_rounded, size: 18, color: StudioColors.primary),
                    )
                  : const SizedBox(key: ValueKey('off'), width: 0),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mini taza dibujada para las tarjetas de tamaño.
class MiniCup extends StatelessWidget {
  const MiniCup({super.key, required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(34, 30 * scale + 6), painter: _MiniCupPainter(scale));
}

class _MiniCupPainter extends CustomPainter {
  _MiniCupPainter(this.scale);
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height - 4;
    final path = Path()
      ..moveTo(2, 2)
      ..lineTo(size.width - 2, 2)
      ..lineTo(size.width - 8, h)
      ..lineTo(8, h)
      ..close();
    canvas.drawPath(path, Paint()..color = StudioColors.latte.withValues(alpha: 0.7));
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeJoin = StrokeJoin.round
        ..color = StudioColors.ink,
    );
  }

  @override
  bool shouldRepaint(covariant _MiniCupPainter old) => old.scale != scale;
}

/// Contenido de cada pestaña de la bandeja: título, pista y panel.
class StagePanel extends StatelessWidget {
  const StagePanel({super.key, required this.title, this.hint, required this.child});
  final String title;
  final String? hint;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: StudioUi.title(dark)),
          if (hint != null) ...[
            const SizedBox(height: 4),
            Text(hint!, style: StudioUi.hint(dark)),
          ],
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
