import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/auth_provider.dart'; 
import 'cart_page.dart';
import 'login_page.dart';
import 'register_page.dart';

enum AuthView { login, register }

class CartTab extends StatefulWidget {
  final VoidCallback? onExploreMenu;

  const CartTab({super.key, this.onExploreMenu});

  @override
  State<CartTab> createState() => _CartTabState();
}

class _CartTabState extends State<CartTab> {
  AuthView _currentView = AuthView.login;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // 1. Si está autenticado, muestra directamente el Carrito
    if (authProvider.isLoggedIn) {
      return CartPage(onExploreMenu: widget.onExploreMenu);
    }

    // 2. Si no está autenticado, alterna entre Login y Register
    if (_currentView == AuthView.register) {
      return RegisterPage(
        onLoginTap: () {
          setState(() {
            _currentView = AuthView.login;
          });
        },
      );
    }

    return LoginPage(
      onRegisterTap: () {
        setState(() {
          _currentView = AuthView.register;
        });
      },
    );
  }
}