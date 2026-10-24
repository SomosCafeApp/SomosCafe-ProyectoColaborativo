import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../widgets/splash/splash_painters.dart';

/// Pantalla de inicio animada de Somos Café: el logo aparece con un
/// rebote suave, sale vapor de la taza, el nombre se revela letra por
/// letra y una barra indica que la app se está preparando.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _intro =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..forward();
  late final AnimationController _loop =
      AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();

  static const _title = 'SOMOS CAFÉ';

  @override
  void dispose() {
    _intro.dispose();
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark
        ? const [Color(0xFF241810), Color(0xFF3A2619)]
        : const [Color(0xFFFFF8EC), Color(0xFFF1DFC4)];
    final ink = dark ? const Color(0xFFF6E9D3) : const Color(0xFF4A2C1B);

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_intro, _loop]),
        builder: (context, _) {
          final t = _intro.value;
          final logoT = Curves.elasticOut.transform((t / 0.55).clamp(0.0, 1.0));
          return Container(
            decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: bg)),
            child: Stack(
              children: [
                Positioned.fill(child: CustomPaint(painter: FloatingBeansPainter(time: _loop.value, dark: dark))),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 190,
                        height: 210,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Positioned.fill(child: CustomPaint(painter: SteamPainter(time: _loop.value * 6, opacity: Curves.easeIn.transform(((t - 0.3) / 0.4).clamp(0.0, 1.0))))),
                            Transform.scale(
                              scale: 0.4 + 0.6 * logoT,
                              child: Opacity(
                                opacity: (t / 0.25).clamp(0.0, 1.0),
                                child: Container(
                                  width: 128,
                                  height: 128,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.35), blurRadius: 28, offset: const Offset(0, 10))],
                                  ),
                                  child: ClipOval(child: Image.asset('assets/images/icon_cafe.png', fit: BoxFit.cover)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var i = 0; i < _title.length; i++) _letter(_title[i], i, t, ink),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Opacity(
                        opacity: ((t - 0.7) / 0.3).clamp(0.0, 1.0),
                        child: Text('Preparando tu café…', style: TextStyle(color: ink.withValues(alpha: 0.7), fontSize: 14, letterSpacing: 0.6)),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 70,
                  right: 70,
                  bottom: 64,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(minHeight: 5, color: AppColors.primary, backgroundColor: AppColors.primary.withValues(alpha: 0.18)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Cada letra entra con un pequeño retraso, subiendo y apareciendo.
  Widget _letter(String ch, int i, double t, Color ink) {
    final start = 0.35 + i * 0.045;
    final p = Curves.easeOutCubic.transform(((t - start) / 0.25).clamp(0.0, 1.0));
    return Opacity(
      opacity: p,
      child: Transform.translate(
        offset: Offset(0, 14 * (1 - p) * math.max(0.0, 1.0)),
        child: Text(ch == ' ' ? '\u00A0' : ch, style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: 3, color: i < 5 ? AppColors.primary : ink)),
      ),
    );
  }
}
