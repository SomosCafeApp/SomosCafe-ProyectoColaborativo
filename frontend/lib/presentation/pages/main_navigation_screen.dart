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

  static const activeBrown = Color(0xFFA2784F);
  static const inactiveColor = Color(0xFF757575);

  void _changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  final List<Map<String, dynamic>> _navItems = [
    {'icon': Icons.home_outlined, 'activeIcon': Icons.home_outlined, 'label': 'Inicio'},
    {'icon': Icons.menu_outlined, 'activeIcon': Icons.menu_outlined, 'label': 'Menú'},
    {'icon': Icons.search_outlined, 'activeIcon': Icons.search_outlined, 'label': 'Buscar'},
    {'icon': Icons.shopping_cart_outlined, 'activeIcon': Icons.shopping_cart_outlined, 'label': 'Carrito'},
    {'icon': Icons.person_outline, 'activeIcon': Icons.person_outline, 'label': 'Perfil'},
  ];

  @override
  Widget build(BuildContext context) {

    // Definimos las páginas dentro del build para pasar _changeTab dinámicamente

    final authProvider = context.watch<AuthProvider>();

    // Lista de páginas dentro del build para responder a cambios de estado y cambiar de pestaña

    final List<Widget> pages = [
      WelcomePage(onOrderNow: () => _changeTab(1)),
      const HomePage(),
      const SearchPage(),
      CartTab(onExploreMenu: () => _changeTab(1)),

      const ProfilePage(),

      // Si hay sesión iniciada muestra ProfilePage, si no, muestra LoginPage
      authProvider.isLoggedIn
          ? const ProfilePage()
          : LoginPage(
              onRegisterTap: () {
                _changeTab(3); // Redirige a la pestaña de autenticación
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
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Color(0xFFEEEEEE), width: 1),
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
                        color: isSelected ? activeBrown : Colors.transparent,
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
                        color: isSelected ? activeBrown : inactiveColor,
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