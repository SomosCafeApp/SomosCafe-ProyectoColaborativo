import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Módulos y páginas
import 'core/theme/app_theme.dart';
import 'presentation/pages/main_navigation_screen.dart';
import 'presentation/pages/welcome_page.dart';

// Providers
import 'presentation/state/cart_provider.dart';
import 'presentation/state/auth_provider.dart';
import 'presentation/state/order_provider.dart';
import 'presentation/state/favorites_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
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
      home: const RootDecider(),
    );
  }
}

class RootDecider extends StatefulWidget {
  const RootDecider({super.key});

  @override
  State<RootDecider> createState() => _RootDeciderState();
}

class _RootDeciderState extends State<RootDecider> {
  bool _guestAcceptedWelcome = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // Si el usuario inició sesión o ya presionó "Pedir ahora" en el WelcomePage
    if (auth.isLoggedIn || _guestAcceptedWelcome) {
      return const MainNavigationScreen();
    }

    return WelcomePage(
      onOrderNow: () {
        setState(() {
          _guestAcceptedWelcome = true;
        });
      },
    );
  }
}