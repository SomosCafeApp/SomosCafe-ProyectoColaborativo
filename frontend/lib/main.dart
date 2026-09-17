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
import 'providers/product_provider.dart';

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
        ChangeNotifierProvider(
          create: (_) => ProductProvider(),
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

/// Restaura la sesión guardada (si existe) antes de mostrar la app,
/// para que un usuario que ya inició sesión no tenga que volver a
/// hacerlo cada vez que abre la app.
class _SessionBootstrap extends StatefulWidget {
  final Widget child;
  const _SessionBootstrap({required this.child});

  @override
  State<_SessionBootstrap> createState() => _SessionBootstrapState();
}

class _SessionBootstrapState extends State<_SessionBootstrap> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    context.read<AuthProvider>().tryAutoLogin().whenComplete(() {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Directionality(
        textDirection: TextDirection.ltr,
        child: ColoredBox(
          color: Colors.white,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    return widget.child;
  }
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

      home: const _SessionBootstrap(child: MainNavigationScreen()),
    );
  }
}