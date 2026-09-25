import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../widgets/chat/chat_fab.dart';
import 'cart_tab.dart';
import 'menu_page.dart';
import 'login_page.dart';
import 'register_page.dart'; // <--- Importación necesaria para el flujo de registro
import 'profile_page.dart';
import 'search_page.dart';
import 'home_page.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _changeTab(int index) {
    setState(() {
      _currentIndex = index;
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Colores de la barra de navegación sincronizados con Figma y AppColors
    final navBackgroundColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final activePillColor = AppColors.primary;
    final activeTextColor = AppColors.primary;
    final inactiveColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final borderColor = isDark ? AppColors.darkSurfaceSubtle : const Color(0xFFEEEEEE);

    final List<Widget> pages = [
      HomePage(onOrderNow: () => _changeTab(1)),
      const MenuPage(),
      const SearchPage(),
      CartTab(onExploreMenu: () => _changeTab(1)),
      authProvider.isLoggedIn
          ? const ProfilePage()
          : const _AuthFlowWrapper(),
    ];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      floatingActionButton: const ChatFab(),
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
                      child: Icon(
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