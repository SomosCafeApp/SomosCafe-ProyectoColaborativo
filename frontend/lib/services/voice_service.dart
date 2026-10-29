import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Estados de la conversación por voz del ChatBot.
enum VoiceState {
  /// Sin actividad.
  idle,

  /// Escuchando al cliente (el texto aparece mientras habla).
  listening,

  /// El motor está cerrando el reconocimiento y entregando el texto final.
  processing,

  /// Leyendo una respuesta en voz alta.
  speaking,
}

/// Voz del ChatBot: reconocimiento de voz (voz → texto) y lectura de
/// respuestas (texto → voz). Usa los motores del teléfono, así que no
/// hay claves ni servicios externos que configurar.
///
/// Nada se envía por voz de forma automática: lo dictado se escribe en
/// la caja de texto para que el cliente lo corrija antes de enviarlo.
class VoiceService extends ChangeNotifier {
  VoiceService();

  final SpeechToText _stt = SpeechToText();
  final FlutterTts _tts = FlutterTts();

  VoiceState _state = VoiceState.idle;
  bool _sttReady = false;
  bool _ttsReady = false;
  String? _localeId;
  String? _errorMessage;
  bool _disposed = false;

  /// Leer en voz alta cada respuesta nueva (lo activa el cliente).
  bool autoRead = false;

  VoiceState get state => _state;
  bool get isListening => _state == VoiceState.listening;
  bool get isSpeaking => _state == VoiceState.speaking;

  /// Último error comprensible para mostrar (null si no hay).
  String? get errorMessage => _errorMessage;

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  void _setState(VoiceState next) {
    if (_state == next) return;
    _state = next;
    _notify();
  }

  // ===================================
  // VOZ → TEXTO
  // ===================================

  Future<bool> _ensureStt() async {
    if (_sttReady) return true;

    try {
      // initialize() pide el permiso del micrófono si hace falta.
      _sttReady = await _stt.initialize(
        onError: _onSttError,
        onStatus: _onSttStatus,
      );
    } catch (_) {
      _sttReady = false;
    }

    if (!_sttReady) {
      _errorMessage = 'No pude usar el micrófono. Revisa el permiso de micrófono en los ajustes del teléfono o que tengas reconocimiento de voz disponible.';
      return false;
    }

    // Español de Colombia si está disponible; si no, cualquier español.
    try {
      final locales = await _stt.locales();
      LocaleName? pick;
      for (final l in locales) {
        if (l.localeId.toLowerCase().replaceAll('-', '_') == 'es_co') pick = l;
      }
      pick ??= locales.cast<LocaleName?>().firstWhere(
            (l) => l!.localeId.toLowerCase().startsWith('es'),
            orElse: () => null,
          );
      _localeId = pick?.localeId;
    } catch (_) {
      _localeId = null;
    }

    return true;
  }

  /// Empieza a escuchar. [onText] recibe el texto reconocido (parcial y
  /// final) cada vez que cambia; [onFinal] se llama una vez al terminar.
  Future<void> startListening({
    required ValueChanged<String> onText,
    VoidCallback? onFinal,
  }) async {
    if (_state == VoiceState.listening || _state == VoiceState.processing) return;

    await stopSpeaking();
    _errorMessage = null;

    if (!await _ensureStt()) {
      _notify();
      return;
    }

    _setState(VoiceState.listening);

    try {
      await _stt.listen(
        onResult: (SpeechRecognitionResult r) {
          onText(r.recognizedWords);
          if (r.finalResult) {
            _setState(VoiceState.idle);
            onFinal?.call();
          }
        },
        localeId: _localeId,
        listenFor: const Duration(seconds: 45),
        pauseFor: const Duration(seconds: 4),
      );
    } catch (_) {
      _errorMessage = 'No pude empezar a escuchar. Inténtalo de nuevo.';
      _setState(VoiceState.idle);
    }
  }

  /// Termina de escuchar y conserva lo reconocido.
  Future<void> stopListening() async {
    if (_state != VoiceState.listening) return;
    _setState(VoiceState.processing);
    try {
      await _stt.stop();
    } catch (_) {}
    // Si el motor no manda el resultado final, no nos quedamos "procesando".
    Timer(const Duration(milliseconds: 1500), () {
      if (_state == VoiceState.processing) _setState(VoiceState.idle);
    });
  }

  /// Cancela: descarta lo dictado.
  Future<void> cancelListening() async {
    try {
      await _stt.cancel();
    } catch (_) {}
    _setState(VoiceState.idle);
  }

  void _onSttStatus(String status) {
    if ((status == 'done' || status == 'notListening') && _state == VoiceState.listening) {
      _setState(VoiceState.processing);
      Timer(const Duration(milliseconds: 1200), () {
        if (_state == VoiceState.processing) _setState(VoiceState.idle);
      });
    }
  }

  void _onSttError(SpeechRecognitionError error) {
    final code = error.errorMsg;

    // "no match" / "speech timeout" no son fallos: simplemente no se oyó nada.
    if (code == 'error_no_match' || code == 'error_speech_timeout') {
      _errorMessage = 'No te escuché bien. Toca el micrófono e inténtalo de nuevo.';
    } else if (code == 'error_permission' || code == 'error_audio') {
      _errorMessage = 'Necesito el permiso de micrófono. Actívalo en los ajustes del teléfono.';
    } else if (code == 'error_network' || code == 'error_network_timeout') {
      _errorMessage = 'El reconocimiento de voz necesita conexión. Revisa tu internet.';
    } else {
      _errorMessage = 'No pude entender el audio. Inténtalo de nuevo o escribe tu mensaje.';
    }

    _setState(VoiceState.idle);
  }

  // ===================================
  // TEXTO → VOZ
  // ===================================

  Future<bool> _ensureTts() async {
    if (_ttsReady) return true;

    try {
      await _tts.setLanguage('es-CO');
      await _tts.setSpeechRate(0.5);
      await _tts.setPitch(1.0);
      _tts.setCompletionHandler(() => _setState(VoiceState.idle));
      _tts.setCancelHandler(() => _setState(VoiceState.idle));
      _tts.setErrorHandler((_) => _setState(VoiceState.idle));
      _ttsReady = true;
    } catch (_) {
      _ttsReady = false;
      _errorMessage = 'No pude activar la lectura en voz alta en este teléfono.';
      _notify();
    }

    return _ttsReady;
  }

  /// Lee [text] en voz alta (sin emojis ni símbolos que suenen raro).
  Future<void> speak(String text) async {
    final clean = text
        .replaceAll(RegExp(r'[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}]', unicode: true), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (clean.isEmpty) return;
    if (_state == VoiceState.listening) await cancelListening();
    if (!await _ensureTts()) return;

    _setState(VoiceState.speaking);

    try {
      await _tts.stop();
      await _tts.speak(clean);
    } catch (_) {
      _errorMessage = 'No pude leer la respuesta en voz alta.';
      _setState(VoiceState.idle);
    }
  }

  Future<void> stopSpeaking() async {
    if (_state != VoiceState.speaking) return;
    try {
      await _tts.stop();
    } catch (_) {}
    _setState(VoiceState.idle);
  }

  @override
  void dispose() {
    _disposed = true;
    _stt.cancel();
    _tts.stop();
    super.dispose();
  }
}
