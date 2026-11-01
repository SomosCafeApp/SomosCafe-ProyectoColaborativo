import 'package:flutter/material.dart';

import 'motion.dart';

/// Microinteracción de selección: cuando [selected] pasa a verdadero, un
/// anillo suave se expande y se desvanece alrededor del elemento. Discreto
/// (medio segundo, sin rebotes) y desactivado con "reducir movimiento".
class SelectionPulse extends StatefulWidget {
  const SelectionPulse({super.key, required this.selected, required this.child, this.radius = 20, this.color});

  final bool selected;
  final Widget child;
  final double radius;

  /// Si es null usa el color primario del tema.
  final Color? color;

  @override
  State<SelectionPulse> createState() => _SelectionPulseState();
}

class _SelectionPulseState extends State<SelectionPulse> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 520));

  @override
  void didUpdateWidget(SelectionPulse old) {
    super.didUpdateWidget(old);
    if (!old.selected && widget.selected && !Motion.reduced(context)) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _c,
              builder: (context, _) {
                final v = Curves.easeOutCubic.transform(_c.value);
                if (_c.value <= 0 || _c.value >= 1) return const SizedBox.shrink();
                return Transform.scale(
                  scale: 1 + 0.09 * v,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(widget.radius),
                      border: Border.all(color: color.withValues(alpha: (1 - v) * 0.55), width: 1.5 + 2.5 * v),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
