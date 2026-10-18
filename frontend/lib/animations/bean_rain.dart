import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'motion.dart';

/// Granos de café que caen una sola vez (≈2.5 s) y desaparecen.
/// Se usa al confirmar un pedido. Colócalo en un `Stack`, dentro de
/// `Positioned.fill(child: IgnorePointer(child: BeanRain()))`.
class BeanRain extends StatefulWidget {
  const BeanRain({
    super.key,
    this.count = 16,
    this.duration = const Duration(milliseconds: 2600),
  });

  final int count;
  final Duration duration;

  @override
  State<BeanRain> createState() => _BeanRainState();
}

class _Bean {
  _Bean({
    required this.x,
    required this.delay,
    required this.size,
    required this.spin,
    required this.sway,
    required this.color,
  });

  final double x;
  final double delay;
  final double size;
  final double spin;
  final double sway;
  final Color color;
}

class _BeanRainState extends State<BeanRain>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.duration);
  late final List<_Bean> _beans;

  static const List<Color> _palette = <Color>[
    Color(0xFF6F4E37),
    Color(0xFF5A3E2B),
    Color(0xFF7B5A40),
    Color(0xFF4A3223),
  ];

  @override
  void initState() {
    super.initState();
    final math.Random rnd = math.Random(11);
    _beans = List<_Bean>.generate(widget.count, (int i) {
      return _Bean(
        x: 0.06 + rnd.nextDouble() * 0.88,
        delay: rnd.nextDouble() * 0.45,
        size: 9 + rnd.nextDouble() * 6,
        spin: (rnd.nextDouble() - 0.5) * 2.5,
        sway: 0.5 + rnd.nextDouble() * 1.2,
        color: _palette[rnd.nextInt(_palette.length)],
      );
    });
  }

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
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? _) {
          if (_controller.isCompleted) return const SizedBox.shrink();
          return SizedBox.expand(
            child: CustomPaint(
              painter: _BeanPainter(_beans, _controller.value),
            ),
          );
        },
      ),
    );
  }
}

class _BeanPainter extends CustomPainter {
  _BeanPainter(this.beans, this.value);

  final List<_Bean> beans;
  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    for (final _Bean b in beans) {
      final double t = ((value - b.delay) / (1 - b.delay)).clamp(0.0, 1.0).toDouble();
      if (t <= 0) continue;

      final double y = -24 + (size.height + 48) * Curves.easeIn.transform(t);
      final double x = b.x * size.width + math.sin(t * math.pi * 2 * b.sway) * 14;
      final double alpha = t < 0.85 ? 1.0 : (1.0 - t) / 0.15;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(b.spin * t * math.pi * 2);

      final Rect oval = Rect.fromCenter(
        center: Offset.zero,
        width: b.size,
        height: b.size * 1.45,
      );
      canvas.drawOval(oval, Paint()..color = b.color.withValues(alpha: alpha));

      // Surco central del grano.
      final Path groove = Path()
        ..moveTo(0, -b.size * 0.62)
        ..quadraticBezierTo(b.size * 0.25, 0, 0, b.size * 0.62);
      canvas.drawPath(
        groove,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = const Color(0xFFD9B99B).withValues(alpha: alpha * 0.8),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _BeanPainter old) => old.value != value;
}
