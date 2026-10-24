import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Módulos y páginas
import 'core/theme/app_theme.dart';
import 'core/utils/push_router.dart';
import 'services/push_service.dart';
import 'pages/main_navigation_screen.dart';
import 'pages/splash_page.dart';
import 'widgets/admin/admin_order_alert_gate.dart';
import 'widgets/events/event_popup_gate.dart';

// Providers
import 'providers/cart_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/order_provider.dart';
import 'providers/active_event_provider.dart';
import 'providers/admin_coupons_provider.dart';
import 'providers/admin_events_provider.dart';
import 'providers/admin_orders_provider.dart';
import 'providers/admin_products_provider.dart';
import 'providers/admin_promotions_provider.dart';
import 'providers/promo_of_the_day_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/font_size_provider.dart';
import 'providers/product_provider.dart';
import 'providers/address_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/reviews_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/coupons_provider.dart';
import 'providers/points_provider.dart';
import 'providers/recipes_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Push (FCM). Si Firebase aún no está configurado, la app sigue
  // funcionando sin notificaciones push.
  PushService.instance.onTap = PushRouter.handle;
  await PushService.instance.init();

  runApp(
    MultiProvider(
      providers: [
        // AuthProvider va primero: CartProvider y FavoritesProvider
        // necesitan leer su token para sincronizar con el backend.
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, CartProvider>(
          create: (_) => CartProvider(),
          update: (_, auth, cart) => (cart ?? CartProvider())..updateAuth(auth.token),
        ),
        ChangeNotifierProxyProvider<AuthProvider, FavoritesProvider>(
          create: (_) => FavoritesProvider(),
          update: (_, auth, favorites) =>
              (favorites ?? FavoritesProvider())..updateAuth(auth.token),
        ),
        ChangeNotifierProxyProvider<AuthProvider, AddressProvider>(
          create: (_) => AddressProvider(),
          update: (_, auth, addresses) =>
              (addresses ?? AddressProvider())..updateAuth(auth.token),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ReviewsProvider>(
          create: (_) => ReviewsProvider(),
          update: (_, auth, reviews) =>
              (reviews ?? ReviewsProvider())..updateAuth(auth.token, auth.user?.id),
        ),
        ChangeNotifierProxyProvider<AuthProvider, NotificationProvider>(
          create: (_) => NotificationProvider(),
          update: (_, auth, notifications) =>
              (notifications ?? NotificationProvider())..updateAuth(auth.token),
        ),
        ChangeNotifierProxyProvider<AuthProvider, PointsProvider>(
          create: (_) => PointsProvider(),
          update: (_, auth, points) => (points ?? PointsProvider())..updateAuth(auth.token, auth.user?.id),
        ),
        // Cupones de recompensas del cliente (catálogo + los que ya canjeó).
        ChangeNotifierProxyProvider<AuthProvider, CouponsProvider>(
          create: (_) => CouponsProvider(),
          update: (_, auth, coupons) => (coupons ?? CouponsProvider())..updateAuth(auth.token),
        ),
        ChangeNotifierProxyProvider<AuthProvider, OrderProvider>(
          create: (_) => OrderProvider(),
          update: (_, auth, orders) => (orders ?? OrderProvider())..updateAuth(auth.token),
        ),
        // Pedidos de todos los usuarios (solo funciona con rol ADMIN;
        // el backend lo exige además de este chequeo en la app).
        ChangeNotifierProxyProvider<AuthProvider, AdminOrdersProvider>(
          create: (_) => AdminOrdersProvider(),
          update: (_, auth, adminOrders) =>
              (adminOrders ?? AdminOrdersProvider())..updateAuth(auth.token, auth.isAdmin),
        ),
        ChangeNotifierProxyProvider<AuthProvider, AdminProductsProvider>(
          create: (_) => AdminProductsProvider(),
          update: (_, auth, products) =>
              (products ?? AdminProductsProvider())..updateAuth(auth.token, auth.isAdmin),
        ),
        ChangeNotifierProxyProvider<AuthProvider, AdminCouponsProvider>(
          create: (_) => AdminCouponsProvider(),
          update: (_, auth, coupons) =>
              (coupons ?? AdminCouponsProvider())..updateAuth(auth.token, auth.isAdmin),
        ),
        ChangeNotifierProxyProvider<AuthProvider, AdminEventsProvider>(
          create: (_) => AdminEventsProvider(),
          update: (_, auth, events) =>
              (events ?? AdminEventsProvider())..updateAuth(auth.token, auth.isAdmin),
        ),
        // Evento activo para el pop-up de inicio (público).
        ChangeNotifierProvider(
          create: (_) => ActiveEventProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, AdminPromotionsProvider>(
          create: (_) => AdminPromotionsProvider(),
          update: (_, auth, promotions) =>
              (promotions ?? AdminPromotionsProvider())..updateAuth(auth.token, auth.isAdmin),
        ),
        // Promo del día del home (pública, no depende de la sesión).
        ChangeNotifierProvider(
          create: (_) => PromoOfTheDayProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ChatProvider>(
          create: (_) => ChatProvider(),
          update: (_, auth, chat) => (chat ?? ChatProvider())..updateAuth(auth.token),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductProvider(),
        ),

        // Recetas del estudio de bebidas (recientes y guardadas).
        ChangeNotifierProxyProvider<AuthProvider, RecipesProvider>(
          create: (_) => RecipesProvider(),
          update: (_, auth, recipes) => (recipes ?? RecipesProvider())..updateAuth(auth.token),
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

  // La splash se ve al menos este tiempo para que la animación termine.
  static const Duration _minSplash = Duration(milliseconds: 2400);

  @override
  void initState() {
    super.initState();
    final minimum = Future<void>.delayed(_minSplash);
    context.read<AuthProvider>().tryAutoLogin().then((_) => minimum).whenComplete(() {
      if (mounted) setState(() => _ready = true);
      // Si la app se abrió tocando una push, ahora que la sesión está
      // restaurada se navega a la pantalla correspondiente.
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => PushService.instance.flushPendingTap(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: _ready
          ? KeyedSubtree(key: const ValueKey('app'), child: widget.child)
          : const SplashPage(key: ValueKey('splash')),
    );
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
      navigatorKey: PushRouter.navigatorKey,
      debugShowCheckedModeBanner: false,

      // Idioma: la app está en español (calendarios, botones del sistema).
      locale: const Locale('es'),
      supportedLocales: const [Locale('es'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,

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

      // El pop-up de evento sale después de restaurar/renovar la sesión.
      home: const _SessionBootstrap(
        child: EventPopupGate(
          child: AdminOrderAlertGate(child: MainNavigationScreen()),
        ),
      ),
    );
  }
}