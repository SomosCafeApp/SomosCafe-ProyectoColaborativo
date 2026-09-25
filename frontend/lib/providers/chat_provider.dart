import 'package:flutter/material.dart';

import '../models/chat_message.dart';
import '../services/api_client.dart';
import '../services/api_exception.dart';

/// Chat con el "barista virtual". Funciona con o sin sesión iniciada:
/// si hay token lo mandamos (el backend asocia la charla al usuario),
/// si no, el backend la guarda como anónima. No usamos
/// ChangeNotifierProxyProvider aquí porque no necesita reaccionar al
/// login/logout: el token simplemente se lee al momento de enviar.
class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  String? _conversationId;
  bool _isSending = false;
  String? _errorMessage;

  List<ChatMessage> get messages => _messages;
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;

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
      _messages.add(ChatMessage(role: 'assistant', content: data['response'] as String? ?? ''));
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
