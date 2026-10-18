import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'motion.dart';

/// Indicador de carga: una taza que se llena y se vacía suavemente.
/// Reemplaza al círculo giratorio en las pantallas completas.
class CoffeeCupLoader extends StatefulWidget {
  const CoffeeCupLoader({super.key, this.size = 48, this.color});

  final double size;

  /// Si es null usa el color primario del tema.
  final Color? color;

  @override
  State<CoffeeCupLoader> createState() => _CoffeeCupLoaderState();
}

class _CoffeeCupLoaderState extends State<CoffeeCupLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Motion.reduced(context)) {
      _controller.value = 0.7;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color color = widget.color ?? Theme.of(context).colorScheme.primary;

    return Center(
      child: Semantics(
        label: 'Cargando',
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _CupPainter(animation: _controller, color: color),
            ),
          ),
        ),
      ),
    );
  }
}

class _CupPainter extends CustomPainter {
  _CupPainter({required this.animation, required this.color})
      : super(repaint: animation);

  final Animation<double> animation;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final double l = w * 0.14;
    final double r = w * 0.70;
    final double top = h * 0.28;
    final double bottom = h * 0.80;
    final double rad = w * 0.10;

    final Path body = Path()
      ..moveTo(l, top)
      ..lineTo(r, top)
      ..lineTo(r - w * 0.04, bottom - rad)
      ..quadraticBezierTo(r - w * 0.05, bottom, r - w * 0.05 - rad, bottom)
      ..lineTo(l + w * 0.05 + rad, bottom)
      ..quadraticBezierTo(l + w * 0.05, bottom, l + w * 0.04, bottom - rad)
      ..close();

    // Café que sube.
    final double level = Curves.easeInOut.transform(animation.value);
    final double fillTop = bottom - (bottom - top) * (0.08 + 0.80 * level);
    final double wave = math.sin(animation.value * math.pi * 4) * h * 0.012;

    canvas.save();
    canvas.clipPath(body);
    canvas.drawRect(
      Rect.fromLTRB(0, fillTop + wave, w, h),
      Paint()..color = color.withValues(alpha: 0.85),
    );
    canvas.restore();

    final Paint stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = math.max(2.0, w * 0.055)
      ..color = color;

    canvas.drawPath(body, stroke);

    // Asa.
    canvas.drawArc(
      Rect.fromLTRB(r - w * 0.10, top + h * 0.07, r + w * 0.17, top + h * 0.33),
      -math.pi / 2,
      math.pi,
      false,
      stroke,
    );

    // Plato.
    canvas.drawLine(
      Offset(l - w * 0.08, bottom + h * 0.06),
      Offset(r + w * 0.04, bottom + h * 0.06),
      stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _CupPainter old) => old.color != color;
}
