import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'motion.dart';

/// Vapor suave que sube de una taza. Se coloca encima del ícono de café.
class CoffeeSteam extends StatefulWidget {
  const CoffeeSteam({
    super.key,
    this.size = 40,
    this.color = Colors.white,
    this.wisps = 3,
  });

  final double size;
  final Color color;
  final int wisps;

  @override
  State<CoffeeSteam> createState() => _CoffeeSteamState();
}

class _CoffeeSteamState extends State<CoffeeSteam>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Motion.reduced(context)) {
      _controller.stop();
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
    return ExcludeSemantics(
      child: IgnorePointer(
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _SteamPainter(
                animation: _controller,
                color: widget.color,
                wisps: widget.wisps,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SteamPainter extends CustomPainter {
  _SteamPainter({
    required this.animation,
    required this.color,
    required this.wisps,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color color;
  final int wisps;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    for (int i = 0; i < wisps; i++) {
      final double phase = (animation.value + i / wisps) % 1.0;
      final double alpha = math.sin(math.pi * phase) * 0.45;
      if (alpha <= 0.01) continue;

      final double x = w * (0.30 + 0.20 * i);
      final double len = h * 0.42;
      final double cy = h * (1.05 - 1.1 * phase);
      final double amp = w * 0.07 * (i.isEven ? 1 : -1);

      final Path path = Path()
        ..moveTo(x, cy + len / 2)
        ..cubicTo(
          x - amp, cy + len / 6,
          x + amp, cy - len / 6,
          x, cy - len / 2,
        );

      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = math.max(1.6, w * 0.055)
          ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 1.2)
          ..color = color.withValues(alpha: alpha),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SteamPainter old) =>
      old.color != color || old.wisps != wisps;
}
