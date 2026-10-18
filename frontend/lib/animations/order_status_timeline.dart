import 'package:flutter/material.dart';

import 'motion.dart';

/// Línea de progreso del pedido (p. ej. Recibido → Preparando → Listo →
/// Entregado). Las barras se llenan al mostrarse y el paso actual late
/// suavemente.
class OrderStatusTimeline extends StatelessWidget {
  const OrderStatusTimeline({
    super.key,
    required this.labels,
    required this.currentStep,
    required this.activeColor,
    required this.inactiveColor,
    required this.textColor,
  });

  final List<String> labels;

  /// Índice (0..labels.length-1) del paso en el que va el pedido.
  final int currentStep;
  final Color activeColor;
  final Color inactiveColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final int n = labels.length;
    final bool finished = currentStep >= n - 1;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List<Widget>.generate(n, (int i) {
        final bool done = i < currentStep || (finished && i == currentStep);
        final bool current = i == currentStep && !finished;

        return Expanded(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 18,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: i == 0
                          ? const SizedBox.shrink()
                          : _Bar(
                              filled: currentStep >= i,
                              index: i,
                              activeColor: activeColor,
                              inactiveColor: inactiveColor,
                            ),
                    ),
                    _Dot(
                      done: done,
                      current: current,
                      activeColor: activeColor,
                      inactiveColor: inactiveColor,
                    ),
                    Expanded(
                      child: i == n - 1
                          ? const SizedBox.shrink()
                          : _Bar(
                              filled: currentStep > i,
                              index: i + 1,
                              activeColor: activeColor,
                              inactiveColor: inactiveColor,
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                labels[i],
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: (done || current) ? FontWeight.w700 : FontWeight.w500,
                  color: (done || current) ? activeColor : textColor,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.filled,
    required this.index,
    required this.activeColor,
    required this.inactiveColor,
  });

  final bool filled;
  final int index;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    final bool reduced = Motion.reduced(context);

    return Center(
      child: SizedBox(
        height: 3,
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: inactiveColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Positioned.fill(
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: filled ? 1 : 0),
                duration: reduced
                    ? Duration.zero
                    : Duration(milliseconds: 350 + 180 * index),
                curve: Curves.easeOutCubic,
                builder: (BuildContext context, double v, Widget? _) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: v,
                      heightFactor: 1,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: activeColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  const _Dot({
    required this.done,
    required this.current,
    required this.activeColor,
    required this.inactiveColor,
  });

  final bool done;
  final bool current;
  final Color activeColor;
  final Color inactiveColor;

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  void _sync() {
    if (widget.current && !Motion.reduced(context)) {
      if (!_pulse.isAnimating) _pulse.repeat();
    } else {
      _pulse.stop();
      _pulse.value = 0;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(covariant _Dot oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool active = widget.done || widget.current;

    return SizedBox(
      width: 18,
      height: 18,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          if (widget.current)
            AnimatedBuilder(
              animation: _pulse,
              builder: (BuildContext context, Widget? _) {
                final double v = _pulse.value;
                return Opacity(
                  opacity: (0.35 * (1 - v)).clamp(0.0, 1.0).toDouble(),
                  child: Container(
                    width: 18 * (0.7 + 0.3 * v),
                    height: 18 * (0.7 + 0.3 * v),
                    decoration: BoxDecoration(
                      color: widget.activeColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),
          AnimatedContainer(
            duration: Motion.base,
            curve: Curves.easeOut,
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: active ? widget.activeColor : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: active ? widget.activeColor : widget.inactiveColor,
                width: 2,
              ),
            ),
            child: widget.done
                ? const Icon(Icons.check_rounded, size: 9, color: Colors.white)
                : null,
          ),
        ],
      ),
    );
  }
}
