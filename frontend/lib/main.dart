import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Módulos y páginas
import 'core/theme/app_theme.dart';
import 'pages/main_navigation_screen.dart';

// Providers
import 'providers/cart_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/order_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/font_size_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => OrderProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => FavoritesProvider(),
        ),

        // Tema
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),

        // Tamaño de fuente
        ChangeNotifierProvider(
          create: (_) => FontSizeProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos el ThemeProvider
    final themeProvider = context.watch<ThemeProvider>();

    // Escuchamos el FontSizeProvider
    final fontSizeProvider = context.watch<FontSizeProvider>();

    // Definimos la escala del texto
    double textScaleFactor = 1.0;

    if (fontSizeProvider.fontSize == 'Pequeño') {
      textScaleFactor = 0.85;
    } else if (fontSizeProvider.fontSize == 'Grande') {
      textScaleFactor = 1.15;
    } else {
      textScaleFactor = 1.0;
    }

    return MaterialApp(
      title: 'SOMOS CafeApp',
      debugShowCheckedModeBanner: false,

      // Temas
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      // Tema seleccionado
      themeMode: themeProvider.themeMode,

      // Escala global de texto
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScaleFactor),
          ),
          child: child ?? const SizedBox(),
        );
      },

      home: const MainNavigationScreen(),
    );
  }
}