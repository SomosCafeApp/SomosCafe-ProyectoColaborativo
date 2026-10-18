import 'package:flutter/material.dart';

import 'motion.dart';

/// Brillo suave que recorre a su hijo; para esqueletos de carga.
class Shimmer extends StatefulWidget {
  const Shimmer({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.period = const Duration(milliseconds: 1500),
  });

  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration period;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.period);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Motion.reduced(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final Color base = widget.baseColor ??
        (dark ? const Color(0xFF2A2523) : const Color(0xFFEAE3DC));
    final Color highlight = widget.highlightColor ??
        (dark ? const Color(0xFF3A3431) : const Color(0xFFF8F4F0));

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (BuildContext context, Widget? child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              colors: <Color>[base, highlight, base],
              stops: const <double>[0.35, 0.5, 0.65],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              transform: _SlidingGradientTransform(-1.0 + 2.0 * _controller.value),
            ).createShader(bounds);
          },
          child: child,
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform(this.slidePercent);

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

/// Rectángulo para usar dentro de un [Shimmer].
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({super.key, this.width, this.height = 14, this.radius = 8});

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Esqueleto de una tarjeta de producto (misma proporción que `ProductCard`).
class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: ShimmerBox(height: double.infinity, radius: 20)),
        SizedBox(height: 10),
        ShimmerBox(width: 110, height: 13),
        SizedBox(height: 6),
        ShimmerBox(height: 10),
        SizedBox(height: 12),
        ShimmerBox(width: 70, height: 12),
      ],
    );
  }
}

/// Cuadrícula de 2 columnas con esqueletos. Va dentro de un [Shimmer].
class ProductGridSkeleton extends StatelessWidget {
  const ProductGridSkeleton({
    super.key,
    this.count = 4,
    this.shrinkWrap = false,
  });

  final int count;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: shrinkWrap,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.68,
      ),
      itemBuilder: (BuildContext context, int index) =>
          const ProductCardSkeleton(),
    );
  }
}

/// Esqueleto de la pantalla de Inicio mientras cargan los productos.
class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: Shimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ShimmerBox(height: 330, radius: 0),
            SizedBox(height: 24),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ShimmerBox(width: 140, height: 18),
                  SizedBox(height: 8),
                  ShimmerBox(width: 200, height: 12),
                  SizedBox(height: 24),
                  SizedBox(
                    height: 560,
                    child: ProductGridSkeleton(count: 4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
