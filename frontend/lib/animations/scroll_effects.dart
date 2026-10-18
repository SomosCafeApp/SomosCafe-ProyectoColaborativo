import 'package:flutter/material.dart';

/// Entrega el desplazamiento (en píxeles) del scroll más cercano para
/// poder animar cosas en función de él.
class ScrollOffsetBuilder extends StatefulWidget {
  const ScrollOffsetBuilder({super.key, required this.builder, this.child});

  final Widget Function(BuildContext context, double offset, Widget? child)
      builder;
  final Widget? child;

  @override
  State<ScrollOffsetBuilder> createState() => _ScrollOffsetBuilderState();
}

class _ScrollOffsetBuilderState extends State<ScrollOffsetBuilder> {
  ScrollPosition? _position;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ScrollPosition? next = Scrollable.maybeOf(context)?.position;
    if (next != _position) {
      _position?.removeListener(_onScroll);
      _position = next;
      _position?.addListener(_onScroll);
    }
  }

  void _onScroll() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _position?.removeListener(_onScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ScrollPosition? p = _position;
    final double offset = (p != null && p.hasPixels) ? p.pixels : 0.0;
    return widget.builder(context, offset, widget.child);
  }
}

/// Fondo con parallax: se mueve más lento que el contenido al hacer scroll.
/// Debe ser hijo directo de un `Stack` (usa `Positioned`).
class ParallaxBackground extends StatelessWidget {
  const ParallaxBackground({
    super.key,
    required this.child,
    this.factor = 0.35,
    this.maxShift = 120,
  });

  final Widget child;

  /// Qué tanto "se queda atrás" respecto al scroll (0 = nada, 1 = fijo).
  final double factor;

  /// Margen extra que se reserva arriba para que nunca se vea un hueco.
  final double maxShift;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      top: -maxShift,
      bottom: 0,
      child: ScrollOffsetBuilder(
        child: child,
        builder: (BuildContext context, double offset, Widget? child) {
          final double shift = (offset * factor).clamp(0.0, maxShift).toDouble();
          return Transform.translate(offset: Offset(0, shift), child: child);
        },
      ),
    );
  }
}

/// El contenido se desvanece suavemente conforme se hace scroll hacia abajo.
class ScrollFade extends StatelessWidget {
  const ScrollFade({super.key, required this.child, this.distance = 260});

  final Widget child;

  /// Píxeles de scroll hasta que desaparece por completo.
  final double distance;

  @override
  Widget build(BuildContext context) {
    return ScrollOffsetBuilder(
      child: child,
      builder: (BuildContext context, double offset, Widget? child) {
        final double o = 1.0 - (offset / distance).clamp(0.0, 1.0).toDouble();
        final double dy = (offset * 0.2).clamp(0.0, 48.0).toDouble();
        return Opacity(
          opacity: o,
          child: Transform.translate(offset: Offset(0, dy), child: child),
        );
      },
    );
  }
}
