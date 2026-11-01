import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../core/constants/app_colors.dart';
import 'api_client.dart';
import 'api_exception.dart';

/// Resultado de intentar dejar este dispositivo listo para recibir push.
enum PushStatus {
  /// Dispositivo registrado en el backend.
  registered,

  /// Firebase no está configurado (falta google-services.json /
  /// GoogleService-Info.plist) o la plataforma no soporta push (web).
  firebaseUnavailable,

  /// El usuario rechazó el permiso de notificaciones del sistema.
  permissionDenied,

  /// Error temporal (sin red, token vencido...). Se reintenta solo.
  failed,
}

class PushRegistrationResult {
  final PushStatus status;

  /// Preferencia guardada en el backend (switch "Push"). Solo es
  /// relevante cuando [status] es [PushStatus.registered].
  final bool pushEnabled;

  const PushRegistrationResult(this.status, {this.pushEnabled = true});
}

/// Notificaciones push con Firebase Cloud Messaging.
///
/// - [init] se llama una vez en `main()`. Si Firebase no está
///   configurado la app sigue funcionando sin push.
/// - [register] / [unregister] enlazan el token FCM del teléfono con
///   la sesión del usuario en el backend (/api/notifications/device-token).
/// - Con la app abierta FCM no muestra nada por sí solo, así que el
///   mensaje se muestra como notificación local.
class PushService {
  PushService._();
  static final PushService instance = PushService._();

  /// Mismo id que usa el backend (utils/push.js) y el AndroidManifest.
  static const String channelId = 'somoscafe_default';

  /// Icono pequeño de la barra de estado (res/drawable*/notification_icon.png):
  /// silueta blanca de la taza. Es el mismo recurso que usa FCM por defecto
  /// (meta-data del manifest), así push y locales se ven idénticas.
  static const String androidIcon = 'notification_icon';

  /// Acento de marca (AppColors.primary) con el que Android tiñe el icono.
  static const Color androidColor = AppColors.primary;

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
    channelId,
    'Notificaciones',
    description: 'Pedidos, promociones y avisos de SOMOS Café',
    importance: Importance.high,
  );

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _firebaseReady = false;
  bool _registering = false;
  String? _deviceToken;
  Map<String, dynamic>? _pendingTap;

  /// Devuelve el JWT actual del usuario (lo asigna NotificationProvider).
  String? Function()? authTokenGetter;

  /// Se llama cuando llega un push con la app abierta (para refrescar
  /// la lista de notificaciones en vivo).
  VoidCallback? onForegroundMessage;

  /// Se llama cuando FCM renueva el token del dispositivo.
  VoidCallback? onDeviceTokenChanged;

  /// Se llama cuando el usuario toca una notificación (la asigna main).
  void Function(Map<String, dynamic> data)? onTap;

  bool get isFirebaseReady => _firebaseReady;

  bool get _platformSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  String get _platformName =>
      defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';

  // ===================================
  // INIT
  // ===================================

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    if (!_platformSupported) return;

    try {
      await Firebase.initializeApp();
    } catch (e) {
      // Sin google-services.json / GoogleService-Info.plist.
      debugPrint('Push desactivado (Firebase no configurado): $e');
      return;
    }

    try {
      await _local.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings(androidIcon),
          // Los permisos se piden con FirebaseMessaging.requestPermission.
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
        onDidReceiveNotificationResponse: (response) {
          final payload = response.payload;
          if (payload == null || payload.isEmpty) return;
          try {
            _handleTap(Map<String, dynamic>.from(jsonDecode(payload) as Map));
          } catch (_) {}
        },
      );

      await _local
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_androidChannel);

      FirebaseMessaging.onMessage.listen(_onForegroundMessage);

      // App en segundo plano y el usuario toca la notificación.
      FirebaseMessaging.onMessageOpenedApp
          .listen((message) => _handleTap(message.data));

      // App cerrada y el usuario la abre tocando la notificación. Se
      // guarda hasta que la sesión esté restaurada (ver flushPendingTap).
      final initial = await FirebaseMessaging.instance.getInitialMessage();
      if (initial != null) _pendingTap = initial.data;

      FirebaseMessaging.instance.onTokenRefresh.listen((token) {
        _deviceToken = token;
        onDeviceTokenChanged?.call();
      });

      _firebaseReady = true;
    } catch (e) {
      debugPrint('Push desactivado (error al iniciar): $e');
    }
  }

  // ===================================
  // REGISTRO DEL DISPOSITIVO
  // ===================================

  /// Pide permiso (si hace falta), obtiene el token FCM y lo registra
  /// en el backend con la sesión actual.
  Future<PushRegistrationResult> register() async {
    if (!_firebaseReady) {
      return const PushRegistrationResult(PushStatus.firebaseUnavailable);
    }

    final authToken = authTokenGetter?.call();
    if (authToken == null) {
      return const PushRegistrationResult(PushStatus.failed);
    }

    if (_registering) {
      return const PushRegistrationResult(PushStatus.failed);
    }
    _registering = true;

    try {
      final settings = await FirebaseMessaging.instance.requestPermission();

      final granted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
              settings.authorizationStatus == AuthorizationStatus.provisional;

      if (!granted) {
        return const PushRegistrationResult(PushStatus.permissionDenied);
      }

      final deviceToken = await FirebaseMessaging.instance.getToken();
      if (deviceToken == null) {
        return const PushRegistrationResult(PushStatus.failed);
      }
      _deviceToken = deviceToken;

      final data = await ApiClient.post(
        '/notifications/device-token',
        body: {'token': deviceToken, 'platform': _platformName},
        token: authToken,
      );

      // Si cerró sesión mientras se registraba, se deshace.
      if (authTokenGetter?.call() == null) {
        unawaited(unregister(authToken));
        return const PushRegistrationResult(PushStatus.failed);
      }

      return PushRegistrationResult(
        PushStatus.registered,
        pushEnabled: data['pushEnabled'] as bool? ?? true,
      );
    } on ApiException catch (e) {
      debugPrint('Push: no se pudo registrar el dispositivo: ${e.message}');
      return const PushRegistrationResult(PushStatus.failed);
    } catch (e) {
      debugPrint('Push: error al registrar el dispositivo: $e');
      return const PushRegistrationResult(PushStatus.failed);
    } finally {
      _registering = false;
    }
  }

  /// Guarda el switch "Push" de este dispositivo en el backend.
  /// Lanza [ApiException] si falla.
  Future<void> setPushPreference(String authToken, bool enabled) async {
    final deviceToken = _deviceToken;
    if (deviceToken == null) {
      throw ApiException('Este dispositivo no está registrado.');
    }

    await ApiClient.patch(
      '/notifications/device-token/preference',
      body: {'token': deviceToken, 'pushEnabled': enabled},
      token: authToken,
    );
  }

  /// Cierre de sesión: desvincula el dispositivo del usuario. Además
  /// elimina el token FCM, así que aunque el backend no se entere
  /// (sin red) ese token deja de funcionar y se limpia solo.
  Future<void> unregister(String authToken) async {
    if (!_firebaseReady) return;

    final deviceToken = _deviceToken;
    _deviceToken = null;

    try {
      if (deviceToken != null) {
        await ApiClient.post(
          '/notifications/device-token/unregister',
          body: {'token': deviceToken},
          token: authToken,
        );
      }
    } catch (_) {
      // Best-effort: no debe bloquear el logout.
    }

    try {
      await FirebaseMessaging.instance.deleteToken();
    } catch (_) {}
  }

  // ===================================
  // MENSAJES
  // ===================================

  /// Ids ya mostrados (con la app abierta). Evita que un mensaje que FCM
  /// reentrega se muestre dos veces como notificación local.
  final List<String> _shownIds = <String>[];

  /// Identificador estable del mensaje: el de la notificación del backend
  /// (`data.notificationId`) y, si no viene, el de FCM.
  static String dedupeKey(RemoteMessage message) {
    final fromData = message.data['notificationId']?.toString() ?? '';
    return fromData.isNotEmpty ? fromData : (message.messageId ?? '');
  }

  /// true si [key] ya se mostró; si no, lo recuerda (máx. 50).
  bool _alreadyShown(String key) {
    if (key.isEmpty) return false;
    if (_shownIds.contains(key)) return true;
    _shownIds.add(key);
    if (_shownIds.length > 50) _shownIds.removeAt(0);
    return false;
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;

    if (notification != null && !_alreadyShown(dedupeKey(message))) {
      await _local.show(
        dedupeKey(message).hashCode & 0x7FFFFFFF,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: androidIcon,
            color: androidColor,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
            presentBadge: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }

    onForegroundMessage?.call();
  }

  void _handleTap(Map<String, dynamic> data) {
    final handler = onTap;
    if (handler == null) {
      _pendingTap = data;
      return;
    }
    handler(data);
  }

  /// Procesa el toque que abrió la app desde cerrada. Llamar cuando la
  /// sesión ya esté restaurada y la UI visible.
  void flushPendingTap() {
    final data = _pendingTap;
    if (data == null) return;
    _pendingTap = null;
    onTap?.call(data);
  }
}
