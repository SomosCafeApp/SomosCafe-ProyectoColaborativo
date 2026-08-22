import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'presentation/pages/welcome_page.dart';
import 'presentation/pages/main_navigation_screen.dart';
import 'presentation/state/cart_provider.dart';
import 'presentation/state/auth_provider.dart';
import 'presentation/state/order_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SOMOS CafeApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          // Si el usuario ya está autenticado entra al sistema principal
          if (auth.isLoggedIn) {
            return const MainNavigationScreen();
          }

          // Si NO está autenticado, abre en la WelcomePage de bienvenida/exploración
          return WelcomePage(
            onOrderNow: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MainNavigationScreen(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}