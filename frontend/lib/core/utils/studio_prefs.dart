import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preferencias del estudio de bebidas: vibración, efectos visuales y
/// animaciones. Se guardan en el dispositivo y aplican a todo el
/// estudio (se cambian dentro del estudio o desde Ajustes).
class StudioPrefs extends ChangeNotifier {
  StudioPrefs._();

  static final StudioPrefs instance = StudioPrefs._();

  static const _kHaptics = 'studio_haptics';
  static const _kEffects = 'studio_effects';
  static const _kAnimations = 'studio_animations';

  /// Vibración táctil (al elegir, al avanzar el vertido, al terminar).
  bool haptics = true;

  /// Partículas, destellos, chorros y salpicaduras decorativas.
  bool effects = true;

  /// Movimientos: transiciones entre etapas, vapor, ondas, cámara.
  bool animations = true;

  /// Mejor puntaje del modo desafío por diseño.
  final Map<String, int> bestScores = {};

  static const _kBest = 'studio_best_';

  bool _loaded = false;

  /// Lee lo guardado (solo la primera vez).
  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final p = await SharedPreferences.getInstance();
      haptics = p.getBool(_kHaptics) ?? true;
      effects = p.getBool(_kEffects) ?? true;
      animations = p.getBool(_kAnimations) ?? true;
      for (final k in p.getKeys().where((k) => k.startsWith(_kBest))) {
        final v = p.getInt(k);
        if (v != null) bestScores[k.substring(_kBest.length)] = v;
      }
      notifyListeners();
    } catch (_) {
      // Sin almacenamiento: se queda con los valores por defecto.
    }
  }

  Future<void> _save(String key, bool value) async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(key, value);
    } catch (_) {}
  }

  /// Anota [points] como mejor puntaje de [design] si lo supera.
  /// Devuelve true si es un récord nuevo.
  bool recordBest(String design, int points) {
    final prev = bestScores[design];
    if (prev != null && points <= prev) return false;
    bestScores[design] = points;
    notifyListeners();
    _saveInt('$_kBest$design', points);
    return true;
  }

  Future<void> _saveInt(String key, int value) async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setInt(key, value);
    } catch (_) {}
  }

  void setHaptics(bool v) {
    if (haptics == v) return;
    haptics = v;
    notifyListeners();
    _save(_kHaptics, v);
  }

  void setEffects(bool v) {
    if (effects == v) return;
    effects = v;
    notifyListeners();
    _save(_kEffects, v);
  }

  void setAnimations(bool v) {
    if (animations == v) return;
    animations = v;
    notifyListeners();
    _save(_kAnimations, v);
  }
}

/// Vibraciones del estudio: respetan la preferencia del usuario.
class StudioHaptics {
  StudioHaptics._();

  static Future<void> _run(Future<void> Function() f) async {
    if (!StudioPrefs.instance.haptics) return;
    try {
      await f();
    } catch (_) {}
  }

  static Future<void> select() => _run(HapticFeedback.selectionClick);
  static Future<void> light() => _run(HapticFeedback.lightImpact);
  static Future<void> medium() => _run(HapticFeedback.mediumImpact);
}
