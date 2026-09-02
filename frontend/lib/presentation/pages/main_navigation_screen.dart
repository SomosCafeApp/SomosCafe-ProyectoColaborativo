import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/auth_provider.dart';
import 'cart_tab.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'profile_page.dart';
import 'search_page.dart';
import 'welcome_page.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _changeTab(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  final List<Map<String, dynamic>> _navItems = const [
    {'icon': Icons.home_outlined, 'activeIcon': Icons.home_outlined, 'label': 'Inicio'},
    {'icon': Icons.menu_outlined, 'activeIcon': Icons.menu_outlined, 'label': 'Menú'},
    {'icon': Icons.search_outlined, 'activeIcon': Icons.search_outlined, 'label': 'Buscar'},
    {'icon': Icons.shopping_cart_outlined, 'activeIcon': Icons.shopping_cart_outlined, 'label': 'Carrito'},
    {'icon': Icons.person_outline, 'activeIcon': Icons.person_outline, 'label': 'Perfil'},
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final activeColor = theme.colorScheme.primary;
    final navBackgroundColor = theme.cardColor;
    final borderColor = isDark ? const Color(0xFF2C1E18) : const Color(0xFFEEEEEE);
    final inactiveColor = isDark ? Colors.white54 : const Color(0xFF757575);

    // Mantenemos la lista declarada reactivamente
    final List<Widget> pages = [
      WelcomePage(onOrderNow: () => _changeTab(1)),
      const HomePage(),
      const SearchPage(),
      CartTab(onExploreMenu: () => _changeTab(1)),
      authProvider.isLoggedIn
          ? const ProfilePage()
          : LoginPage(
              onRegisterTap: () {
                _changeTab(4);
              },
            ),
    ];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
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

              return Expanded(
                child: GestureDetector(
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
                          color: isSelected ? activeColor : Colors.transparent,
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
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? activeColor : inactiveColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}