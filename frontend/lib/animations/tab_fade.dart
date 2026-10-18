import 'package:flutter/material.dart';

import 'motion.dart';

/// Suaviza el cambio de pestaña: al cambiar [index] el contenido entra con
/// un fundido corto y 10 px de desplazamiento. No reconstruye las pestañas
/// (conservan su estado, igual que con IndexedStack).
class TabFade extends StatefulWidget {
  const TabFade({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<TabFade> createState() => _TabFadeState();
}

class _TabFadeState extends State<TabFade> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
    value: 1.0,
  );
  late final CurvedAnimation _curve =
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

  @override
  void didUpdateWidget(covariant TabFade oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index && !Motion.reduced(context)) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      child: widget.child,
      builder: (BuildContext context, Widget? child) {
        final double v = _curve.value;
        return Opacity(
          opacity: (0.4 + 0.6 * v).clamp(0.0, 1.0).toDouble(),
          child: Transform.translate(offset: Offset(0, 10 * (1 - v)), child: child),
        );
      },
    );
  }
}
