import 'package:flutter/material.dart';

/// Transición discreta para TODAS las pantallas que se abren con
/// `MaterialPageRoute`: un fundido suave con un desplazamiento mínimo
/// hacia arriba (~2.5 % del alto). Nada de zoom ni barridos.
class SoftPageTransitionsBuilder extends PageTransitionsBuilder {
  const SoftPageTransitionsBuilder();

  static final Animatable<double> _fade = CurveTween(curve: Curves.easeOut);
  static final Animatable<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.025),
    end: Offset.zero,
  ).chain(CurveTween(curve: Curves.easeOutCubic));

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // La primera pantalla de la app no se anima.
    if (route.isFirst) return child;

    return FadeTransition(
      opacity: animation.drive(_fade),
      child: SlideTransition(
        position: animation.drive(_slide),
        child: child,
      ),
    );
  }
}

/// Se conecta una sola vez en `AppTheme` (`pageTransitionsTheme`).
class AppMotion {
  AppMotion._();

  static const PageTransitionsTheme pageTransitions = PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: SoftPageTransitionsBuilder(),
      TargetPlatform.fuchsia: SoftPageTransitionsBuilder(),
      TargetPlatform.windows: SoftPageTransitionsBuilder(),
      TargetPlatform.linux: SoftPageTransitionsBuilder(),
      // iOS y macOS conservan su transición nativa (gesto de volver).
    },
  );
}
