import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'motion.dart';

/// Miniatura del producto que vuela hasta la pestaña del carrito.
///
/// 1. `CartTabIcon` (en la barra inferior) se registra como destino.
/// 2. Quien agrega al carrito llama a `CartFly.launch(...)`.
class CartFly {
  CartFly._();

  /// Contexto del ícono del carrito en la barra inferior (lo registra
  /// `CartTabIcon`). No usa GlobalKey para evitar claves duplicadas.
  static BuildContext? targetContext;

  /// Sube cada vez que una miniatura llega al carrito.
  static final ValueNotifier<int> arrival = ValueNotifier<int>(0);

  static void launch(
    BuildContext context, {
    required Rect from,
    String? imageUrl,
  }) {
    if (Motion.reduced(context)) return;

    final BuildContext? target = targetContext;
    if (target == null || !target.mounted) return;

    final OverlayState? overlay = Overlay.maybeOf(context, rootOverlay: true);
    final RenderObject? targetBox = target.findRenderObject();
    if (overlay == null || targetBox is! RenderBox || !targetBox.attached) {
      return;
    }

    final Offset to = targetBox.localToGlobal(targetBox.size.center(Offset.zero));

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (BuildContext _) => _FlyingThumb(
        from: from,
        to: to,
        imageUrl: imageUrl,
        onDone: () {
          entry.remove();
          entry.dispose();
          arrival.value++;
        },
      ),
    );
    overlay.insert(entry);
  }
}

class _FlyingThumb extends StatefulWidget {
  const _FlyingThumb({
    required this.from,
    required this.to,
    required this.imageUrl,
    required this.onDone,
  });

  final Rect from;
  final Offset to;
  final String? imageUrl;
  final VoidCallback onDone;

  @override
  State<_FlyingThumb> createState() => _FlyingThumbState();
}

class _FlyingThumbState extends State<_FlyingThumb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward().whenComplete(() {
      if (mounted) widget.onDone();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _thumb(double size) {
    final String? url = widget.imageUrl;
    final Widget placeholder = ColoredBox(
      color: const Color(0xFF6F4E37),
      child: Icon(Icons.coffee_rounded, color: Colors.white, size: size * 0.5),
    );

    Widget image = placeholder;
    if (url != null && url.isNotEmpty) {
      image = url.startsWith('http')
          ? Image.network(url, fit: BoxFit.cover, errorBuilder: (_, _, _) => placeholder)
          : Image.asset(url, fit: BoxFit.cover, errorBuilder: (_, _, _) => placeholder);
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipOval(child: image),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Offset a = widget.from.center;
    final Offset b = widget.to;
    final Offset control = Offset((a.dx + b.dx) / 2, math.min(a.dy, b.dy) - 110);
    final double startSize = math.min(widget.from.shortestSide, 72);

    return Positioned(
      left: 0,
      top: 0,
      right: 0,
      bottom: 0,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? _) {
            final double t = Curves.easeInOut.transform(_controller.value);
            final double u = 1 - t;
            final Offset p = a * (u * u) + control * (2 * u * t) + b * (t * t);
            final double size = startSize + (20 - startSize) * t;
            final double opacity = _controller.value < 0.85
                ? 1.0
                : (1.0 - _controller.value) / 0.15;

            return Stack(
              children: <Widget>[
                Positioned(
                  left: p.dx - size / 2,
                  top: p.dy - size / 2,
                  width: size,
                  height: size,
                  child: Opacity(
                    opacity: opacity.clamp(0.0, 1.0).toDouble(),
                    child: _thumb(size),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Ícono del carrito en la barra inferior: se registra como destino del
/// vuelo, rebota cuando llega un producto y muestra un contador que
/// "late" cuando cambia la cantidad.
class CartTabIcon extends StatefulWidget {
  const CartTabIcon({super.key, required this.count, required this.child});

  final int count;
  final Widget child;

  @override
  State<CartTabIcon> createState() => _CartTabIconState();
}

class _CartTabIconState extends State<CartTabIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounce = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );

  late final Animation<double> _scale = TweenSequence<double>(
    <TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.0, end: 1.22)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.22, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 60,
      ),
    ],
  ).animate(_bounce);

  @override
  void initState() {
    super.initState();
    CartFly.targetContext = context;
    CartFly.arrival.addListener(_onArrival);
  }

  void _onArrival() {
    if (mounted) _bounce.forward(from: 0);
  }

  @override
  void dispose() {
    CartFly.arrival.removeListener(_onArrival);
    if (CartFly.targetContext == context) CartFly.targetContext = null;
    _bounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int count = widget.count;

    return ScaleTransition(
      scale: _scale,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: <Widget>[
          widget.child,
          Positioned(
            // El ícono está centrado en una pastilla de 56x32.
            top: 0,
            right: 11,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (Widget child, Animation<double> animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: count > 0
                  ? Container(
                      key: ValueKey<int>(count),
                      constraints: const BoxConstraints(minWidth: 16),
                      height: 16,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        count > 99 ? '99+' : '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(key: ValueKey<int>(0)),
            ),
          ),
        ],
      ),
    );
  }
}
