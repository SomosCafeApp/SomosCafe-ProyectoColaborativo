import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'motion.dart';

/// Círculo que aparece y una palomita que se dibuja (≈0.8 s).
class AnimatedCheck extends StatefulWidget {
  const AnimatedCheck({
    super.key,
    this.size = 110,
    this.color = Colors.green,
    this.background,
  });

  final double size;
  final Color color;
  final Color? background;

  @override
  State<AnimatedCheck> createState() => _AnimatedCheckState();
}

class _AnimatedCheckState extends State<AnimatedCheck>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Motion.reduced(context)) {
      _controller.value = 1.0;
    } else if (_controller.value == 0 && !_controller.isAnimating) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: CustomPaint(
        painter: _CheckPainter(
          animation: _controller,
          color: widget.color,
          background: widget.background ?? widget.color.withValues(alpha: 0.12),
        ),
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  _CheckPainter({
    required this.animation,
    required this.color,
    required this.background,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color color;
  final Color background;

  @override
  void paint(Canvas canvas, Size size) {
    final double t = animation.value;
    final Offset c = size.center(Offset.zero);

    // 0 → 0.5: el círculo aparece.
    final double circleT = Curves.easeOutCubic.transform((t / 0.5).clamp(0.0, 1.0).toDouble());
    canvas.drawCircle(
      c,
      size.width / 2 * circleT,
      Paint()..color = background,
    );

    // 0.4 → 1: la palomita se dibuja.
    final double checkT = Curves.easeOut.transform(((t - 0.4) / 0.6).clamp(0.0, 1.0).toDouble());
    if (checkT <= 0) return;

    final double w = size.width;
    final Path check = Path()
      ..moveTo(w * 0.30, w * 0.52)
      ..lineTo(w * 0.45, w * 0.67)
      ..lineTo(w * 0.72, w * 0.37);

    final Path partial = Path();
    for (final ui.PathMetric m in check.computeMetrics()) {
      partial.addPath(m.extractPath(0, m.length * checkT), Offset.zero);
    }

    canvas.drawPath(
      partial,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = w * 0.07
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _CheckPainter old) =>
      old.color != color || old.background != background;
}
