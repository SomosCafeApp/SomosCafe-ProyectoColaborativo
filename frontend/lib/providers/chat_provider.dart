import 'package:flutter/material.dart';

import '../models/chat_message.dart';
import '../services/api_client.dart';
import '../services/api_exception.dart';

/// Chat con el "barista virtual". Funciona con o sin sesión iniciada:
/// si hay token lo mandamos (el backend asocia la charla al usuario),
/// si no, el backend la guarda como anónima.
///
/// Sigue el mismo patrón que CartProvider/AddressProvider: [updateAuth]
/// se llama vía ChangeNotifierProxyProvider cada vez que cambia la
/// sesión, para poder:
/// - Al iniciar sesión (anónimo -> logueado): limpiar el chat que se
///   traía como invitado y cargar el historial real de esa cuenta.
/// - Al cerrar sesión (logueado -> anónimo): limpiar el chat, para
///   que el siguiente "anónimo" empiece de cero.
class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  String? _conversationId;
  String? _token;
  bool _isSending = false;
  bool _isLoadingHistory = false;
  String? _errorMessage;

  List<ChatMessage> get messages => _messages;
  bool get isSending => _isSending;
  bool get isLoadingHistory => _isLoadingHistory;
  String? get errorMessage => _errorMessage;

  /// Llamado por el ChangeNotifierProxyProvider cada vez que cambia
  /// la sesión (login, logout o restauración automática al abrir la app).
  void updateAuth(String? token) {
    final wasLoggedIn = _token != null;
    final isLoggedIn = token != null;
    _token = token;

    if (isLoggedIn && !wasLoggedIn) {
      // Anónimo -> logueado: empezamos un chat nuevo y vacío, y
      // enseguida cargamos el historial real de esta cuenta.
      _messages.clear();
      _conversationId = null;
      _errorMessage = null;
      notifyListeners();
      _loadHistory(token);
    } else if (!isLoggedIn && wasLoggedIn) {
      // Logueado -> anónimo (logout): limpiamos todo para que el
      // siguiente "anónimo" no vea la charla de la cuenta anterior.
      reset();
    }
  }

  Future<void> _loadHistory(String token) async {
    _isLoadingHistory = true;
    notifyListeners();

    try {
      final data = await ApiClient.get('/chat/history', token: token);
      final rawMessages = data['messages'] as List? ?? [];

      _messages
        ..clear()
        ..addAll(rawMessages
            .whereType<Map<String, dynamic>>()
            .map(ChatMessage.fromJson));
      _conversationId = data['conversationId'] as String?;
    } on ApiException {
      // Si falla la carga del historial no es crítico: el usuario
      // simplemente empieza una conversación nueva con esa cuenta.
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String text, {String? token}) async {
    final message = text.trim();
    if (message.isEmpty || _isSending) return;

    _messages.add(ChatMessage(role: 'user', content: message));
    _isSending = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await ApiClient.post(
        '/chat',
        token: token,
        body: {
          'message': message,
          if (_conversationId != null) 'conversationId': _conversationId,
        },
      );

      _conversationId = data['conversationId'] as String?;
      _messages.add(ChatMessage.fromJson({
        'role': 'assistant',
        'content': data['response'],
        'products': data['products'],
      }));
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _messages.add(ChatMessage(
        role: 'assistant',
        content: 'Lo siento, no pude responder ahora mismo (${e.message}).',
      ));
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  void reset() {
    _messages.clear();
    _conversationId = null;
    _errorMessage = null;
    notifyListeners();
  }
}
