import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'motion.dart';

/// Indicador de carga de SOMOS CAFÉ: una taza estilizada que se llena
/// de café mientras sube un hilo de vapor. Sustituye al círculo giratorio
/// en pantallas y secciones (los botones conservan su spinner pequeño).
/// Con "reducir movimiento" se queda quieto y sigue siendo legible.
class CoffeeCupLoader extends StatefulWidget {
  const CoffeeCupLoader({super.key, this.size = 48, this.color, this.label});

  final double size;

  /// Si es null usa el color primario del tema.
  final Color? color;

  /// Texto accesible (por defecto "Cargando").
  final String? label;

  @override
  State<CoffeeCupLoader> createState() => _CoffeeCupLoaderState();
}

/// Nombre de marca del mismo indicador.
typedef BrandLoader = CoffeeCupLoader;

class _CoffeeCupLoaderState extends State<CoffeeCupLoader> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Motion.reduced(context)) {
      _controller
        ..stop()
        ..value = 0.7;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
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
        label: widget.label ?? 'Cargando',
        liveRegion: true,
        child: ExcludeSemantics(
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: RepaintBoundary(
              child: CustomPaint(painter: CupLoaderPainter(animation: _controller, color: color)),
            ),
          ),
        ),
      ),
    );
  }
}

/// Dibujo de la taza con vapor. `animation` va de 0 a 1 en bucle.
class CupLoaderPainter extends CustomPainter {
  CupLoaderPainter({required this.animation, required this.color}) : super(repaint: animation);

  final Animation<double> animation;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final t = animation.value;

    final double l = w * 0.14;
    final double r = w * 0.70;
    final double top = h * 0.36;
    final double bottom = h * 0.84;
    final double rad = w * 0.10;

    final Path body = Path()
      ..moveTo(l, top)
      ..lineTo(r, top)
      ..lineTo(r - w * 0.04, bottom - rad)
      ..quadraticBezierTo(r - w * 0.05, bottom, r - w * 0.05 - rad, bottom)
      ..lineTo(l + w * 0.05 + rad, bottom)
      ..quadraticBezierTo(l + w * 0.05, bottom, l + w * 0.04, bottom - rad)
      ..close();

    // El café sube y baja suave (ida y vuelta con la misma fase).
    final double tri = t < 0.5 ? t * 2 : (1 - t) * 2;
    final double level = Curves.easeInOut.transform(tri);
    final double fillTop = bottom - (bottom - top) * (0.1 + 0.78 * level);
    final double wave = math.sin(t * math.pi * 6) * h * 0.012;

    canvas.save();
    canvas.clipPath(body);
    canvas.drawRect(Rect.fromLTRB(0, fillTop + wave, w, h), Paint()..color = color.withValues(alpha: 0.85));
    canvas.restore();

    final Paint stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = math.max(2.0, w * 0.055)
      ..color = color;

    canvas.drawPath(body, stroke);
    canvas.drawArc(Rect.fromLTRB(r - w * 0.10, top + h * 0.07, r + w * 0.17, top + h * 0.33), -math.pi / 2, math.pi, false, stroke);
    canvas.drawLine(Offset(l - w * 0.08, bottom + h * 0.06), Offset(r + w * 0.04, bottom + h * 0.06), stroke);

    // Tres hilos de vapor desfasados que suben y se desvanecen.
    for (var i = 0; i < 3; i++) {
      final p = (t + i / 3) % 1.0;
      final x = l + (r - l) * (0.25 + 0.25 * i) + math.sin((p + i) * math.pi * 2) * w * 0.03;
      final y = top - h * 0.04 - p * h * 0.26;
      final alpha = math.sin(p * math.pi).clamp(0.0, 1.0) * 0.7;
      canvas.drawLine(
        Offset(x, y),
        Offset(x + math.sin(p * math.pi * 3) * w * 0.02, y - h * 0.07),
        Paint()
          ..strokeCap = StrokeCap.round
          ..strokeWidth = math.max(1.6, w * 0.04)
          ..color = color.withValues(alpha: alpha),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CupLoaderPainter old) => old.color != color;
}
