import 'dart:async';

import 'package:flutter/material.dart';

import 'motion.dart';

/// Hace aparecer a su hijo con un desvanecido y un pequeño deslizamiento.
///
/// ```dart
/// FadeSlideIn(child: MiSeccion())
/// FadeSlideIn.staggered(index: i, child: MiTarjeta()) // en listas/grids
/// ```
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 380),
    this.offset = const Offset(0, 14),
    this.curve = Curves.easeOutCubic,
  });

  /// Para listas y grids: el retraso crece con [index] pero se reinicia cada
  /// [cycle] elementos, así los que aparecen al hacer scroll no se demoran.
  factory FadeSlideIn.staggered({
    Key? key,
    required int index,
    required Widget child,
    Duration step = const Duration(milliseconds: 60),
    int cycle = 6,
    Duration duration = const Duration(milliseconds: 380),
    Offset offset = const Offset(0, 14),
    Curve curve = Curves.easeOutCubic,
  }) {
    final int steps = index < 0 ? 0 : index % cycle;
    return FadeSlideIn(
      key: key,
      delay: step * steps,
      duration: duration,
      offset: offset,
      curve: curve,
      child: child,
    );
  }

  final Widget child;
  final Duration delay;
  final Duration duration;

  /// Desplazamiento inicial en píxeles.
  final Offset offset;
  final Curve curve;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _progress;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _progress = CurvedAnimation(parent: _controller, curve: widget.curve);

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      _timer = Timer(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Motion.reduced(context)) {
      _timer?.cancel();
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progress.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progress,
      child: widget.child,
      builder: (BuildContext context, Widget? child) {
        final double v = _progress.value;
        return Opacity(
          opacity: v.clamp(0.0, 1.0).toDouble(),
          child: Transform.translate(
            offset: widget.offset * (1.0 - v),
            child: child,
          ),
        );
      },
    );
  }
}

/// Versión ultra discreta (fundido + 10 px) para pantallas secundarias:
/// Ajustes, Perfil, Direcciones, Notificaciones, etc.
class SoftFadeIn extends StatelessWidget {
  const SoftFadeIn({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      duration: Motion.base,
      offset: const Offset(0, 10),
      child: child,
    );
  }
}
