import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'art_pour.dart';
import 'latte_pour_session.dart';
import 'studio_colors.dart';

/// Vista previa fija del arte latte: la silueta del diseño y lo vertido
/// hasta ahora, centrados y sin que el dedo ni la jarra los tapen, con
/// un anillo que muestra el avance. Se actualiza mientras se vierte.
class ArtMiniPreview extends StatelessWidget {
  const ArtMiniPreview({super.key, required this.pour, this.size = 84});
  final LattePourSession pour;
  final double size;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ListenableBuilder(
      listenable: pour,
      builder: (context, _) {
        if (!pour.hasDesign) return const SizedBox.shrink();
        return Semantics(
          label: 'Vista previa del arte latte, ${(pour.progress * 100).round()} por ciento',
          child: Container(
            width: size,
            height: size,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: StudioColors.panel(dark).withValues(alpha: 0.92),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 10, offset: const Offset(0, 3))],
            ),
            child: CustomPaint(painter: _PreviewPainter(pour, dark)),
          ),
        );
      },
    );
  }
}

class _PreviewPainter extends CustomPainter {
  _PreviewPainter(this.pour, this.dark) : super(repaint: pour);
  final LattePourSession pour;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;

    // Anillo de avance.
    final ring = Rect.fromCircle(center: c, radius: r - 1.5);
    canvas.drawCircle(
      c,
      r - 1.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = StudioColors.muted(dark).withValues(alpha: 0.2),
    );
    canvas.drawArc(
      ring,
      -math.pi / 2,
      math.pi * 2 * pour.progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 3
        ..color = pour.completed ? const Color(0xFF4E9A52) : StudioColors.primary,
    );

    // Café con el diseño.
    final inner = r - 7;
    canvas.drawCircle(c, inner, Paint()..color = const Color(0xFFB57C4D));
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: inner)));
    final scale = inner * 0.95 / 1.2;
    ArtPour.paintLive(canvas, c, scale / ArtPour.kx, scale / ArtPour.ky, pour, guide: true);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PreviewPainter old) => old.pour != pour || old.dark != dark;
}
