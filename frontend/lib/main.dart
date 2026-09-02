import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Módulos y páginas
import 'package:mi_proyecto_cafe/presentation/pages/main_navigation_screen.dart';

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
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // 1. Previene el parpadeo mientras AuthProvider revisa la sesión
    if (auth.isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 2. Carga MainNavigationScreen desde el inicio enviando la clave única.
    // Al renderizar MainNavigationScreen con el Scaffold completo, el BottomBar 
    // estará disponible inmediatamente sin importar el estado de autenticación.
    return const MainNavigationScreen(
      key: ValueKey('MainNavigationScreen'),
    );
  }
}