import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/menu_category_request.dart';
import '../providers/active_event_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/chat/chat_fab.dart';
import '../widgets/drink_studio/drink_studio_launcher.dart';
import 'cart_tab.dart';
import 'menu_page.dart';
import 'login_page.dart';
import 'register_page.dart'; // <--- Importación necesaria para el flujo de registro
import 'profile_page.dart';
import 'search_page.dart';
import 'home_page.dart';

import '../animations/animations.dart';
import '../providers/cart_provider.dart';
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  int? _lastEventPopupRequest;
  MenuCategoryRequest? _menuCategoryRequest;
  int _menuRequestCount = 0;

  /// Si el usuario toca la push de un evento, se vuelve a la pestaña
  /// Inicio (donde sale el pop-up).
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final requests = Provider.of<ActiveEventProvider>(context).popupRequestCount;
    if (_lastEventPopupRequest != null && requests != _lastEventPopupRequest) {
      _currentIndex = 0;
    }
    _lastEventPopupRequest = requests;
  }

  void _changeTab(int index) {
    // Al volver a Inicio se recargan los productos: así "Lo Más Popular"
    // refleja las calificaciones más recientes y no las del arranque.
    if (index == 0 && _currentIndex != 0) {
      context.read<ProductProvider>().fetchProducts();
    }
    setState(() {
      _currentIndex = index;
    });
  }

  /// Abre la pestaña Menú con la categoría indicada ya seleccionada.
  void _openMenuCategory(String categoryId) {
    setState(() {
      _menuCategoryRequest = MenuCategoryRequest(
        categoryId: categoryId,
        requestId: ++_menuRequestCount,
      );
      _currentIndex = 1;
    });
  }

  final List<Map<String, dynamic>> _navItems = const [
    {'icon': Icons.home_outlined, 'activeIcon': Icons.home_rounded, 'label': 'Inicio'},
    {'icon': Icons.menu_outlined, 'activeIcon': Icons.menu_rounded, 'label': 'Menú'},
    {'icon': Icons.search_outlined, 'activeIcon': Icons.search_rounded, 'label': 'Buscar'},
    {'icon': Icons.shopping_cart_outlined, 'activeIcon': Icons.shopping_cart_rounded, 'label': 'Carrito'},
    {'icon': Icons.person_outline, 'activeIcon': Icons.person_rounded, 'label': 'Perfil'},
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final cartCount = context.select<CartProvider, int>((c) => c.itemCount);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Colores de la barra de navegación sincronizados con Figma y AppColors
    final navBackgroundColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final activePillColor = AppColors.primary;
    final activeTextColor = AppColors.primary;
    final inactiveColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final borderColor = isDark ? AppColors.darkSurfaceSubtle : const Color(0xFFEEEEEE);

    final List<Widget> pages = [
      HomePage(
        onOrderNow: () => _changeTab(1),
        onCategorySelected: _openMenuCategory,
      ),
      MenuPage(categoryRequest: _menuCategoryRequest),
      const SearchPage(),
      CartTab(onExploreMenu: () => _changeTab(1)),
      authProvider.isLoggedIn
          ? const ProfilePage()
          : const _AuthFlowWrapper(),
    ];

    return Stack(
      children: [
        Scaffold(
          resizeToAvoidBottomInset: false,
          body: TabFade(
            index: _currentIndex,
            child: IndexedStack(
              index: _currentIndex,
              children: pages,
            ),
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Container(
              height: 65,
              decoration: BoxDecoration(
                color: navBackgroundColor,
                border: Border(
                  top: BorderSide(color: borderColor, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(_navItems.length, (index) {
                  final isSelected = _currentIndex == index;
                  final item = _navItems[index];

                  return GestureDetector(
                    onTap: () => _changeTab(index),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 56,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isSelected ? activePillColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: index == 3
                              ? CartTabIcon(
                                  count: cartCount,
                                  child: Icon(
                                    isSelected ? item['activeIcon'] : item['icon'],
                                    color: isSelected ? Colors.white : inactiveColor,
                                    size: 22,
                                  ),
                                )
                              : Icon(
                                  isSelected ? item['activeIcon'] : item['icon'],
                                  color: isSelected ? Colors.white : inactiveColor,
                                  size: 22,
                                ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item['label'],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                            color: isSelected ? activeTextColor : inactiveColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
        // El FAB vive FUERA del Scaffold (en este Stack exterior), no en
        // su slot `floatingActionButton`. Así Scaffold nunca detecta que
        // hay un FAB y no le reserva espacio extra al SnackBar (que es
        // lo que lo empujaba hacia arriba); al ser el último hijo del
        // Stack, además siempre se pinta encima de cualquier SnackBar.
        Positioned(
          right: 16,
          bottom: 65 + MediaQuery.of(context).padding.bottom + 16,
          child: const ChatFab(),
        ),
        // Acceso único al minijuego Estudio de bebidas, sobre el ChatBot,
        // en Menú (no depende de las bebidas disponibles). En Carrito
        // vive en el encabezado: ahí el panel fijo del total ocupa el
        // lugar donde flotaría y taparía el precio.
        if (_currentIndex == 1)
          Positioned(
            right: 22,
            bottom: 65 + MediaQuery.of(context).padding.bottom + 16 + 56 + 12,
            child: const DrinkStudioLauncher(),
          ),
      ],
    );
  }
}

// Widget encargado de alternar entre Login y Registro manteniendo la Navbar
class _AuthFlowWrapper extends StatefulWidget {
  const _AuthFlowWrapper();

  @override
  State<_AuthFlowWrapper> createState() => _AuthFlowWrapperState();
}

class _AuthFlowWrapperState extends State<_AuthFlowWrapper> {
  bool _showLogin = true;

  @override
  Widget build(BuildContext context) {
    if (_showLogin) {
      return LoginPage(
        onRegisterTap: () {
          setState(() {
            _showLogin = false;
          });
        },
      );
    } else {
      return RegisterPage(
        onLoginTap: () {
          setState(() {
            _showLogin = true;
          });
        },
      );
    }
  }
}