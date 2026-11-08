import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/utils/studio_prefs.dart';
import 'studio_colors.dart';

/// Ráfaga de destellos que celebra un logro (arte latte terminado, bebida
/// lista). Se dispara una vez cada vez que [tick] cambia y [active] es
/// verdadero. Respeta «efectos» y «animaciones» de las preferencias del
/// estudio y «reducir movimiento» del sistema. No recibe toques.
class StudioSparkles extends StatefulWidget {
  const StudioSparkles({super.key, required this.tick, this.active = true, this.origin = const Alignment(0, 0.1)});

  final int tick;
  final bool active;

  /// Punto del que salen los destellos (por defecto, sobre el vaso).
  final Alignment origin;

  @override
  State<StudioSparkles> createState() => _StudioSparklesState();
}

class _StudioSparklesState extends State<StudioSparkles> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
  late int _seen = widget.tick;

  @override
  void didUpdateWidget(StudioSparkles old) {
    super.didUpdateWidget(old);
    if (widget.tick == _seen) return;
    _seen = widget.tick;
    final prefs = StudioPrefs.instance;
    final reduced = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (widget.active && prefs.effects && prefs.animations && !reduced) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          if (_c.value <= 0 || _c.value >= 1) return const SizedBox.shrink();
          return CustomPaint(
            size: Size.infinite,
            painter: _SparklePainter(t: _c.value, origin: widget.origin, low: StudioPrefs.instance.lowPower),
          );
        },
      ),
    );
  }
}

class _SparklePainter extends CustomPainter {
  _SparklePainter({required this.t, required this.origin, required this.low});

  final double t;
  final Alignment origin;
  final bool low;

  static const _colors = [Color(0xFFFFE08A), Color(0xFFFFFFFF), Color(0xFFFFC107), StudioColors.latte, Color(0xFFFFB77A)];

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(7);
    final center = origin.alongSize(size);
    final n = low ? 12 : 26;
    final reach = size.shortestSide * 0.55;
    final ease = Curves.easeOutCubic.transform(t);
    for (var i = 0; i < n; i++) {
      final angle = rnd.nextDouble() * math.pi * 2;
      final dist = (0.35 + rnd.nextDouble() * 0.65) * reach;
      final delay = rnd.nextDouble() * 0.25;
      final life = ((t - delay) / (1 - delay)).clamp(0.0, 1.0).toDouble();
      if (life <= 0) continue;
      final k = Curves.easeOutCubic.transform(life);
      // Sube y se abre; una leve gravedad al final les da peso.
      final pos = center + Offset(math.cos(angle) * dist * k, math.sin(angle) * dist * k - 28 * k + 46 * life * life);
      final fade = math.sin(life * math.pi).clamp(0.0, 1.0).toDouble();
      final color = _colors[i % _colors.length].withValues(alpha: fade);
      final r = (2.2 + rnd.nextDouble() * 3.6) * (0.6 + 0.4 * (1 - life));
      if (i % 3 == 0) {
        _star(canvas, pos, r * 2.2, color, life * math.pi);
      } else {
        canvas.drawCircle(pos, r, Paint()..color = color);
      }
    }
    // Halo cálido que se apaga rápido: da la sensación de «brillo».
    final halo = (1 - ease).clamp(0.0, 1.0).toDouble();
    canvas.drawCircle(
      center,
      reach * 0.5 * (0.5 + ease),
      Paint()..shader = RadialGradient(colors: [const Color(0xFFFFE08A).withValues(alpha: 0.28 * halo), Colors.transparent]).createShader(Rect.fromCircle(center: center, radius: reach * 0.5 * (0.5 + ease))),
    );
  }

  void _star(Canvas canvas, Offset c, double r, Color color, double rot) {
    final p = Path();
    for (var i = 0; i < 8; i++) {
      final a = rot + i * math.pi / 4;
      final rr = i.isEven ? r : r * 0.32;
      final o = c + Offset(math.cos(a) * rr, math.sin(a) * rr);
      i == 0 ? p.moveTo(o.dx, o.dy) : p.lineTo(o.dx, o.dy);
    }
    canvas.drawPath(p..close(), Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _SparklePainter old) => old.t != t;
}
