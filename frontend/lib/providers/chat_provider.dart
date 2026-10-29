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

  /// Se llama cuando una acción del chat cambió el carrito (agregar o
  /// vaciar): la pantalla lo conecta con CartProvider para recargarlo.
  VoidCallback? onCartChanged;

  /// Último mensaje del cliente que falló, para poder reintentarlo.
  String? _failedText;
  String? _failedSelectId;
  bool get canRetry => _failedText != null && !_isSending;

  /// Quita el estado "recién llegado" y las propuestas ya resueltas de
  /// los mensajes anteriores: solo la última propuesta es accionable.
  void _settleOlder() {
    for (var i = 0; i < _messages.length; i++) {
      final m = _messages[i];
      if (m.isFresh || m.pending != null) {
        _messages[i] = m.copyWith(isFresh: false, clearPending: true);
      }
    }
  }

  /// Envía un mensaje. [selectProductId] se usa al elegir una tarjeta de
  /// producto: el servidor valida que exista y siga disponible.
  Future<void> sendMessage(String text, {String? token, String? selectProductId}) async {
    final message = text.trim();
    if (message.isEmpty || _isSending) return;

    _settleOlder();
    _messages.add(ChatMessage(role: 'user', content: message));
    await _post(message, token: token, selectProductId: selectProductId);
  }

  /// Reintenta el último mensaje que no pudo responderse.
  Future<void> retry({String? token}) async {
    final text = _failedText;
    if (text == null || _isSending) return;

    // Quita el aviso de error; el mensaje del cliente se conserva.
    if (_messages.isNotEmpty && _messages.last.isError) _messages.removeLast();
    await _post(text, token: token, selectProductId: _failedSelectId);
  }

  Future<void> _post(String message, {String? token, String? selectProductId}) async {
    _isSending = true;
    _errorMessage = null;
    _failedText = null;
    _failedSelectId = null;
    notifyListeners();

    try {
      final data = await ApiClient.post(
        '/chat',
        token: token ?? _token,
        body: {
          'message': message,
          if (_conversationId != null) 'conversationId': _conversationId,
          if (selectProductId != null) 'selectProductId': selectProductId,
        },
      );

      _handleReply(data);
    } on ApiException catch (e) {
      _failedText = message;
      _failedSelectId = selectProductId;
      _errorMessage = e.message;
      _messages.add(ChatMessage(
        role: 'assistant',
        isError: true,
        content: e.statusCode == 429
            ? e.message
            : 'No pude responder ahora mismo. Revisa tu conexión e inténtalo de nuevo.',
      ));
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  /// Confirma o cancela la propuesta de carrito del último mensaje.
  /// El carrito solo cambia en el servidor, tras esta confirmación.
  Future<void> answerPending({required bool accept, String? token}) async {
    if (_isSending || _conversationId == null) return;

    final last = _messages.isNotEmpty ? _messages.last : null;
    final pending = last?.pending;
    if (pending == null) return;

    _isSending = true;
    notifyListeners();

    try {
      final data = await ApiClient.post(
        '/chat/confirm',
        token: token ?? _token,
        body: {
          'conversationId': _conversationId,
          'actionId': pending.id,
          'accept': accept,
        },
      );

      _handleReply(data);
    } on ApiException catch (e) {
      // 409: la propuesta venció o ya se resolvió.
      _settleOlder();
      _messages.add(ChatMessage(
        role: 'assistant',
        isError: e.statusCode != 409,
        content: e.statusCode == 409
            ? e.message
            : 'No pude completar la acción. Revisa tu conexión e inténtalo de nuevo.',
      ));
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  void _handleReply(Map<String, dynamic> data) {
    _conversationId = data['conversationId'] as String? ?? _conversationId;

    _settleOlder();
    _messages.add(ChatMessage.fromJson({
      'role': 'assistant',
      'content': data['response'],
      'products': data['products'],
      'whatsapp': data['whatsapp'],
      'quickReplies': data['quickReplies'],
      'pendingAction': data['pendingAction'],
      'actions': data['actions'],
    }, fresh: true));

    if (data['cartUpdated'] == true) onCartChanged?.call();
  }

  /// Empieza una conversación nueva: archiva la actual en el servidor
  /// (si hay sesión) y limpia la pantalla.
  Future<void> startNewConversation() async {
    final token = _token;
    reset();

    if (token == null) return;

    try {
      await ApiClient.post('/chat/new', token: token, body: const {});
    } on ApiException {
      // Si falla, la pantalla ya quedó limpia; el historial se
      // recargará con lo anterior la próxima vez.
    }
  }

  void reset() {
    _messages.clear();
    _conversationId = null;
    _errorMessage = null;
    _failedText = null;
    _failedSelectId = null;
    notifyListeners();
  }
}
