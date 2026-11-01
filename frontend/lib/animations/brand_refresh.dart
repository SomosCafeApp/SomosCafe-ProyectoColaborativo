import 'package:flutter/material.dart';

import 'coffee_cup_loader.dart';
import 'motion.dart';

/// Deslizar para actualizar con el indicador de marca (la taza).
///
/// Usa [RefreshIndicator] por debajo (así el gesto, la accesibilidad y la
/// actualización real son los de Flutter) pero oculta su círculo y dibuja
/// la taza de SOMOS CAFÉ: crece mientras se tira, se anima mientras
/// [onRefresh] trabaja y desaparece al terminar.
///
///  * Solo aparece al tirar hacia abajo: no se muestra en la carga inicial
///    ni en la carga de más resultados al llegar al final de una lista.
///  * Ignora tirones mientras ya hay una actualización en curso.
class BrandRefresh extends StatefulWidget {
  const BrandRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
    this.color,
    this.backgroundColor,
    this.displacement = 40,
    this.edgeOffset = 0,
    this.notificationPredicate = defaultScrollNotificationPredicate,
    this.minVisible = const Duration(milliseconds: 450),
  });

  final Future<void> Function() onRefresh;
  final Widget child;
  final Color? color;
  final Color? backgroundColor;
  final double displacement;
  final double edgeOffset;
  final ScrollNotificationPredicate notificationPredicate;

  /// Tiempo mínimo que se ve el indicador, para que no parpadee si los
  /// datos llegan al instante.
  final Duration minVisible;

  @override
  State<BrandRefresh> createState() => _BrandRefreshState();
}

class _BrandRefreshState extends State<BrandRefresh> {
  /// 0..1: cuánto se ha tirado (para escalar la taza).
  final ValueNotifier<double> _pull = ValueNotifier<double>(0);
  final ValueNotifier<bool> _refreshing = ValueNotifier<bool>(false);
  static const double _trigger = 90;

  @override
  void dispose() {
    _pull.dispose();
    _refreshing.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    if (_refreshing.value) return;
    _refreshing.value = true;
    final started = DateTime.now();
    try {
      await widget.onRefresh();
    } finally {
      final left = widget.minVisible - DateTime.now().difference(started);
      if (left > Duration.zero) await Future<void>.delayed(left);
      if (mounted) {
        _refreshing.value = false;
        _pull.value = 0;
      }
    }
  }

  bool _onScroll(ScrollNotification n) {
    if (!widget.notificationPredicate(n) || _refreshing.value) return false;
    if (n is ScrollUpdateNotification) {
      // Física con rebote (iOS): los píxeles pasan a negativo.
      _pull.value = n.metrics.pixels < 0 ? (-n.metrics.pixels / _trigger).clamp(0.0, 1.0) : 0;
    } else if (n is OverscrollNotification && n.dragDetails != null && n.overscroll < 0) {
      // Física con tope (Android): se acumula el sobredesplazamiento.
      _pull.value = (_pull.value + (-n.overscroll / _trigger)).clamp(0.0, 1.0);
    } else if (n is ScrollEndNotification) {
      if (!_refreshing.value) _pull.value = 0;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;
    final reduced = Motion.reduced(context);
    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: _onScroll,
          child: RefreshIndicator(
            onRefresh: _run,
            color: Colors.transparent,
            backgroundColor: Colors.transparent,
            elevation: 0,
            strokeWidth: 0.01,
            displacement: widget.displacement,
            edgeOffset: widget.edgeOffset,
            notificationPredicate: widget.notificationPredicate,
            child: widget.child,
          ),
        ),
        Positioned(
          top: widget.edgeOffset + 8,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: ValueListenableBuilder<bool>(
              valueListenable: _refreshing,
              builder: (context, refreshing, _) => ValueListenableBuilder<double>(
                valueListenable: _pull,
                builder: (context, pull, _) {
                  final visible = refreshing || pull > 0.02;
                  final scale = refreshing ? 1.0 : (0.4 + 0.6 * pull);
                  return Center(
                    child: AnimatedOpacity(
                      opacity: visible ? 1 : 0,
                      duration: reduced ? Duration.zero : const Duration(milliseconds: 160),
                      child: Transform.translate(
                        offset: Offset(0, refreshing ? 14 : 14 * pull),
                        child: Transform.scale(
                          scale: scale,
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: widget.backgroundColor ?? Theme.of(context).colorScheme.surface,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.16), blurRadius: 10, offset: const Offset(0, 3))],
                            ),
                            child: visible
                                ? Semantics(
                                    liveRegion: true,
                                    label: refreshing ? 'Actualizando' : 'Suelta para actualizar',
                                    child: CoffeeCupLoader(size: 30, color: color, label: 'Actualizando'),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
