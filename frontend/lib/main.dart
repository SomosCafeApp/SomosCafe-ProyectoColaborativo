import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Módulos y páginas
import 'package:mi_proyecto_cafe/presentation/pages/main_navigation_screen.dart';
import 'package:mi_proyecto_cafe/presentation/pages/welcome_page.dart';

// Providers
import 'package:mi_proyecto_cafe/presentation/state/theme_provider.dart';
import 'package:mi_proyecto_cafe/presentation/state/cart_provider.dart';
import 'package:mi_proyecto_cafe/presentation/state/auth_provider.dart';
import 'package:mi_proyecto_cafe/presentation/state/order_provider.dart';
import 'package:mi_proyecto_cafe/presentation/state/favorites_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
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
    // Escucha activamente el ThemeProvider para redibujar la app al cambiar de modo
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'SOMOS CafeApp',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.lightTheme,
      darkTheme: themeProvider.darkTheme,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
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

    // Si el usuario está autenticado o presionó 'Pedir ahora' en el WelcomePage,
    // se le redirige al contenedor principal con la barra de navegación inferior adaptativa
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