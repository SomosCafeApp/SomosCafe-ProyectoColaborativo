import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'studio_colors.dart';

/// Ambiente del estudio:
/// - Detrás: un fondo cálido y limpio (NUNCA azul).
/// - Delante: partículas pequeñas junto a los bordes de la pantalla. Cada
///   partícula es UNA sola: con la temperatura se transforma de forma
///   continua (llama/ascua ↔ copo de nieve) cambiando de forma, tamaño,
///   opacidad y dirección del movimiento, sin aparecer ni desaparecer de
///   golpe. No cubren el centro ni los controles.
class AmbientPainter extends CustomPainter {
  AmbientPainter({
    required this.time,
    required this.cold,
    required this.front,
    required this.dark,
    this.strength = 1,
    this.quality = 1,
  });

  final double time;

  /// 0 = caliente … 1 = fría (progresivo).
  final double cold;
  final bool front;
  final bool dark;

  /// 0..1: qué tan presentes están las partículas.
  final double strength;

  /// 0.5 (dispositivo modesto) … 1 (completo): cantidad de partículas.
  final double quality;

  static const int _count = 30;

  @override
  void paint(Canvas canvas, Size size) {
    if (front) {
      _particles(canvas, size);
    } else {
      _background(canvas, size);
    }
  }

  void _background(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, 0.35),
          radius: 0.95,
          colors: [dark ? const Color(0xFF3A2619) : StudioColors.beige, Colors.transparent],
        ).createShader(rect),
    );
  }

  /// Posición base de la partícula [i] en una franja junto a un borde.
  Offset _anchor(int i, Size size, math.Random rnd) {
    final band = switch (i % 4) {
      0 => Rect.fromLTWH(0, 0, size.width * 0.16, size.height),
      1 => Rect.fromLTWH(size.width * 0.84, 0, size.width * 0.16, size.height),
      2 => Rect.fromLTWH(0, 0, size.width, size.height * 0.1),
      _ => Rect.fromLTWH(0, size.height * 0.92, size.width, size.height * 0.08),
    };
    return Offset(band.left + rnd.nextDouble() * band.width, band.top + rnd.nextDouble() * band.height);
  }

  void _particles(Canvas canvas, Size size) {
    final rnd = math.Random(17);
    final n = (_count * quality.clamp(0.4, 1.0)).round();
    final travel = size.height * 0.2;
    for (var i = 0; i < _count; i++) {
      // El azar se consume SIEMPRE (aunque la partícula se omita) para que
      // cada una conserve su sitio y su fase al cambiar la calidad.
      final anchor = _anchor(i, size, rnd);
      final speed = 0.5 + rnd.nextDouble();
      final phase = rnd.nextDouble() * math.pi * 2;
      final scale = 0.7 + rnd.nextDouble() * 0.9;
      final lag = rnd.nextDouble();
      if (i >= n) continue;

      // Cada partícula se transforma en un momento distinto de la
      // transición (escalonado), así el cambio se ve como una ola.
      final m = _smooth((cold - lag * 0.45) / 0.55);

      // Vida cíclica: nace, se mueve y se desvanece (misma fase para las
      // dos formas, así la opacidad no salta al transformarse).
      final p = (time * 0.06 * speed + phase / (math.pi * 2)) % 1.0;
      final env = math.sin(p * math.pi);
      final alpha = strength * env * 0.8;
      if (alpha < 0.02) continue;

      // Dirección: sube (llama, calor) → se detiene al transformarse →
      // cae (nieve). Un solo número continuo, sin saltos.
      final dir = 2 * m - 1;
      final dy = dir * p * travel;
      final dx = math.sin(time * (0.8 + 0.5 * m) + phase) * (4 + 5 * m);
      final y = (anchor.dy + dy) % size.height;
      ThermalParticle.paint(canvas, Offset(anchor.dx + dx, y), 4.4 * scale, m, alpha, time * (0.3 + 0.5 * m) + phase, time, dark);
    }
  }

  static double _smooth(double t) {
    final x = t.clamp(0.0, 1.0).toDouble();
    return x * x * (3 - 2 * x);
  }

  @override
  bool shouldRepaint(covariant AmbientPainter old) => old.time != time || old.cold != cold || old.strength != strength || old.dark != dark || old.quality != quality;
}

/// Una partícula que es llama (m = 0) y copo de nieve (m = 1) y todo lo
/// que hay en medio: el brillo cálido se encoge, la llama se afina hasta
/// desaparecer y brotan los brazos del cristal.
class ThermalParticle {
  ThermalParticle._();

  static void paint(Canvas canvas, Offset c, double r, double m, double alpha, double rot, double time, bool dark) {
    if (alpha <= 0.01) return;
    final warm = (1 - m).clamp(0.0, 1.0).toDouble();
    final ice = m.clamp(0.0, 1.0).toDouble();

    if (warm > 0.02) {
      // Brillo de brasa que se apaga y se encoge.
      _glow(canvas, c, r * (2.1 - 0.9 * m), const Color(0xFFF6B04A), alpha * 0.5 * warm);
      // Llama: se afina (escala en X) y baja de altura al enfriarse.
      final flick = 1 + math.sin(time * 6 + rot * 3) * 0.12;
      final h = r * 1.7 * flick * (0.35 + 0.65 * warm);
      final w = r * 1.05 * warm;
      final path = Path()
        ..moveTo(c.dx, c.dy - h)
        ..quadraticBezierTo(c.dx + w, c.dy - r * 0.2, c.dx, c.dy + r * warm)
        ..quadraticBezierTo(c.dx - w, c.dy - r * 0.2, c.dx, c.dy - h)
        ..close();
      canvas.drawPath(path, Paint()..color = const Color(0xFFF08A2E).withValues(alpha: alpha * 0.85 * warm));
      canvas.drawCircle(c.translate(0, r * 0.25), r * 0.38 * warm, Paint()..color = const Color(0xFFFFD27A).withValues(alpha: alpha * warm));
    }

    if (ice > 0.02) {
      _glow(canvas, c, r * (1.2 + 0.8 * ice), const Color(0xFFBFE3F2), alpha * 0.3 * ice);
      // Copo: los brazos crecen desde el centro y, al final, se ramifican.
      final arm = r * (0.3 + 0.8 * ice);
      final line = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 0.8 + 0.5 * ice
        ..color = (dark ? Colors.white : const Color(0xFF7FB6D1)).withValues(alpha: alpha * ice);
      for (var k = 0; k < 3; k++) {
        final a = rot + m * math.pi / 3 + k * math.pi / 3;
        final dir = Offset(math.cos(a), math.sin(a));
        canvas.drawLine(c - dir * arm, c + dir * arm, line);
        if (ice > 0.55) {
          // Ramitas en V a ambos lados de cada brazo.
          final t = (ice - 0.55) / 0.45;
          for (final sign in const [-1.0, 1.0]) {
            final base = c + dir * arm * 0.62 * sign;
            final out = math.atan2(dir.dy * sign, dir.dx * sign);
            for (final side in const [-0.6, 0.6]) {
              final back = out + math.pi + side;
              canvas.drawLine(base, base + Offset(math.cos(back), math.sin(back)) * arm * 0.3 * t, line);
            }
          }
        }
      }
      canvas.drawCircle(c, r * 0.22 * ice, Paint()..color = Colors.white.withValues(alpha: alpha * ice));
    }
  }

  static void _glow(Canvas canvas, Offset c, double r, Color color, double alpha) {
    if (alpha <= 0.01 || r <= 0.5) return;
    canvas.drawCircle(
      c,
      r,
      Paint()..shader = RadialGradient(colors: [color.withValues(alpha: alpha), color.withValues(alpha: 0)]).createShader(Rect.fromCircle(center: c, radius: r)),
    );
  }
}

/// Vapor del café caliente: varias capas de bocanadas semitransparentes
/// que nacen en la superficie, suben con una turbulencia suave, se
/// ensanchan, cambian de opacidad y se disipan. Cada bocanada es un
/// degradado radial (sin trazos ni líneas rectas); un único degradado
/// unitario se reutiliza para todas, así es barato de dibujar.
class SteamField {
  SteamField._();

  static Shader? _puff;

  static Shader get _unitPuff => _puff ??= const RadialGradient(
        colors: [Color(0xFFFFFFFF), Color(0x99FFFFFF), Color(0x00FFFFFF)],
        stops: [0, 0.45, 1],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: 1));

  static double _hash(int n) {
    final x = math.sin(n * 127.1 + 311.7) * 43758.5453;
    return x - x.floorToDouble();
  }

  /// [origin]: punto de la superficie donde nace; [width]: ancho de la
  /// boca; [height]: hasta dónde sube. Con [spread] > 0 (vista desde
  /// arriba) el vapor no sube: se abre en abanico hacia el espectador.
  static void paint(
    Canvas canvas, {
    required Offset origin,
    required double width,
    required double height,
    required double time,
    required double strength,
    required bool dark,
    double quality = 1,
    double spread = 0,
  }) {
    if (strength <= 0.02 || width <= 1) return;
    final high = quality >= 0.75;
    final layers = high ? 3 : 2;
    final perLayer = high ? 6 : 4;
    final tint = dark ? StudioColors.cream : Colors.white;
    final shader = _unitPuff;

    for (var l = 0; l < layers; l++) {
      final depth = l / (layers - 1);
      final speed = 0.12 + 0.05 * l;
      for (var i = 0; i < perLayer; i++) {
        final s1 = _hash(l * 17 + i);
        final s2 = _hash(l * 31 + i * 7 + 3);
        final p = (time * speed + s1) % 1.0;
        final env = math.pow(math.sin(p * math.pi), 1.25).toDouble();
        // Opacidad que respira, distinta en cada bocanada.
        final flicker = 0.65 + 0.35 * math.sin(time * 0.9 + s1 * 20);
        final alpha = strength * 0.3 * env * flicker * (1 - 0.3 * depth);
        if (alpha < 0.01) continue;

        // Turbulencia: dos ondas lentas que se ensanchan al subir.
        final sway = math.sin(time * 1.3 + s1 * 9 + p * 5) * width * 0.07 * p + math.sin(time * 0.6 + s2 * 11 + p * 9) * width * 0.04;
        final radius = width * (0.1 + 0.3 * p) * (0.75 + 0.5 * s2);

        var x = origin.dx + (s1 - 0.5) * width * (0.45 + 0.8 * p) + sway;
        var y = origin.dy - p * height * (0.8 + 0.2 * s2);
        if (spread > 0) {
          // Desde arriba: se abre radialmente y se agranda.
          final a = s1 * math.pi * 2 + time * 0.1;
          final fx = origin.dx + math.cos(a) * p * width * 0.55 + sway;
          final fy = origin.dy + math.sin(a) * p * width * 0.55 * 0.9;
          x += (fx - x) * spread;
          y += (fy - y) * spread;
        }

        canvas.save();
        canvas.translate(x, y);
        canvas.scale(radius, radius * 1.25);
        canvas.drawRect(
          const Rect.fromLTRB(-1, -1, 1, 1),
          Paint()
            ..shader = shader
            ..colorFilter = ColorFilter.mode(tint.withValues(alpha: alpha), BlendMode.modulate),
        );
        canvas.restore();
      }
    }
  }
}

/// Degradado del contorno del vaso según la temperatura: caliente en
/// crema, ámbar y terracota; frío en blanco helado, turquesa y azul. Es
/// un barrido que gira despacio y pasa de una paleta a otra de forma
/// continua. Es sutil a propósito: acompaña la luz, no es un borde de neón.
class ThermalOutline {
  ThermalOutline._();

  static const List<Color> _warm = [Color(0xFFF6E3C0), Color(0xFFE8A94E), Color(0xFFC4673F), Color(0xFFF6E3C0)];
  static const List<Color> _cold = [Color(0xFFEFFBFF), Color(0xFF45C4C9), Color(0xFF5B9BD5), Color(0xFFEFFBFF)];

  static Color tone(double cold, int i) => Color.lerp(_warm[i % 4], _cold[i % 4], cold.clamp(0.0, 1.0))!;

  static Shader shader(Rect bounds, double cold, double time) => SweepGradient(
        colors: [for (var i = 0; i < 4; i++) tone(cold, i)],
        transform: GradientRotation(time * 0.5),
      ).createShader(bounds);

  /// Dibuja el contorno de [path]. Con [glow] añade un resplandor suave
  /// por fuera (se omite en dispositivos modestos).
  static void stroke(Canvas canvas, Path path, Rect bounds, {required double cold, required double time, double width = 2.6, double intensity = 1, bool glow = true, bool crisp = true, bool dark = false}) {
    if (intensity <= 0.01) return;
    final sh = shader(bounds, cold, time);
    if (glow) {
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = width * 3.4
          ..shader = sh
          ..colorFilter = ColorFilter.mode(Colors.white.withValues(alpha: (dark ? 0.26 : 0.18) * intensity), BlendMode.modulate)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }
    if (!crisp) return;
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = width
        ..shader = sh
        ..colorFilter = ColorFilter.mode(Colors.white.withValues(alpha: 0.55 * intensity), BlendMode.modulate),
    );
  }
}
