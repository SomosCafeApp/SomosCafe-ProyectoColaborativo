import 'package:flutter/material.dart';

/// Permite que cualquier pantalla apilada sobre la navegación principal
/// (DrinkStudio, detalle de producto, etc.) pida cambiar de pestaña sin
/// abrir pantallas duplicadas encima.
///
/// Ejemplo: en vez de apilar un LoginPage sobre DrinkStudio, se vuelve a
/// la navegación principal y se abre la pestaña Perfil, que ya contiene
/// el flujo de inicio de sesión / registro con la barra inferior.
class TabNavigation {
  TabNavigation._();

  /// Índices de las pestañas de MainNavigationScreen.
  static const int homeTab = 0;
  static const int menuTab = 1;
  static const int searchTab = 2;
  static const int cartTab = 3;
  static const int profileTab = 4;

  /// Petición pendiente. [requestId] cambia en cada petición para que
  /// la misma pestaña pueda pedirse dos veces seguidas.
  static final ValueNotifier<TabRequest?> request = ValueNotifier<TabRequest?>(null);
  static int _counter = 0;

  /// Cierra todas las pantallas apiladas y muestra la pestaña [tab].
  static void goToTab(BuildContext context, int tab) {
    Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
    request.value = TabRequest(tab: tab, requestId: ++_counter);
  }

  static void goToProfile(BuildContext context) => goToTab(context, profileTab);
}

class TabRequest {
  const TabRequest({required this.tab, required this.requestId});
  final int tab;
  final int requestId;
}
