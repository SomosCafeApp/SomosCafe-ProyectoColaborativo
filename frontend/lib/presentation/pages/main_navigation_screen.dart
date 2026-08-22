import 'package:flutter/material.dart';
import 'cart_page.dart';
import 'home_page.dart';
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

  // Mapeo corregido: WelcomePage para Inicio y HomePage para el catálogo/menú
  final List<Widget> _pages = [
    const WelcomePage(), 
    const HomePage(),    
    const SearchPage(),  
    const CartPage(),    
    const ProfilePage(), 
  ];

  final List<Map<String, dynamic>> _navItems = [
    {'icon': Icons.home_outlined, 'activeIcon': Icons.home_outlined, 'label': 'Inicio'},
    {'icon': Icons.menu_outlined, 'activeIcon': Icons.menu_outlined, 'label': 'Menú'},
    {'icon': Icons.search_outlined, 'activeIcon': Icons.search_outlined, 'label': 'Buscar'},
    {'icon': Icons.shopping_cart_outlined, 'activeIcon': Icons.shopping_cart_outlined, 'label': 'Carrito'},
    {'icon': Icons.person_outline, 'activeIcon': Icons.person_outline, 'label': 'Perfil'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        height: 75,
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
              onTap: () => setState(() => _currentIndex = index),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 56,
                    height: 36,
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
                  const SizedBox(height: 3),
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
    );
  }
}