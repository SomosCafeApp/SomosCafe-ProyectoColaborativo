import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/utils/latte_pour_engine.dart';
import '../../core/utils/studio_prefs.dart';
import 'latte_art_shapes.dart';

/// Estado del vertido interactivo del arte latte.
///
/// Separa tres cosas que antes eran una sola (`latteArt`):
///  * el DISEÑO elegido (la silueta guía),
///  * la POSICIÓN del vertido (dónde está la jarra ahora mismo),
///  * el PROGRESO del relleno (cuánta silueta ya tiene leche).
///
/// El diseño solo cuenta como "arte latte de la bebida" cuando el
/// usuario lo termina ([completed]); elegir una figura nunca lo
/// completa. Vive dentro del provider del estudio, así el avance se
/// conserva aunque el usuario cambie de etapa y vuelva.
///
/// Es un `ChangeNotifier` propio: mover el dedo a 60 fps solo
/// repinta el vaso, no reconstruye toda la pantalla. Los cambios
/// "gruesos" (elegir, terminar, reiniciar) avisan por [onCoarseChange].
class LattePourSession extends ChangeNotifier {
  LattePourSession({this.onCoarseChange, this.onDone});

  final VoidCallback? onCoarseChange;

  /// Se llama una vez al terminar el diseño (antes del aviso general),
  /// para que quien la use registre récords, etc.
  final void Function(LattePourSession session)? onDone;

  /// Modo desafío: al terminar se calcula una puntuación. En modo libre
  /// queda en false y no hay puntos de ningún tipo.
  bool scoring = false;

  /// El último diseño terminado superó el mejor puntaje guardado.
  bool newRecord = false;

  ArtScore? _score;

  /// Puntuación del diseño recién terminado (solo con [scoring]).
  ArtScore? get score => _score;

  static const int _grid = 32;
  static const double _extent = 1.2;

  String _design = '';
  Path? _silhouette;
  Path? _guide;
  LattePourEngine? _engine;
  bool _completed = false;
  bool _disposed = false;

  /// Sube al terminar el diseño (dispara la animación de satisfacción).
  int doneTick = 0;

  /// Sube al reiniciar el vertido.
  int resetTick = 0;

  // Jarra
  bool _pouring = false;
  Offset _target = Offset.zero;
  Offset _jug = Offset.zero;
  double _lean = 0;
  double _flow = 0;
  int _milestone = 0;

  // ───────────── Lectura ─────────────

  String get design => _design;
  bool get hasDesign => _design.isNotEmpty;

  /// Silueta rellenable (coordenadas unitarias) y su versión punteada.
  Path? get silhouette => _silhouette;
  Path? get guide => _guide;

  /// Diseño terminado: es lo único que pasa a la bebida.
  bool get completed => _completed;

  /// Hay un diseño elegido que aún no está terminado.
  bool get pending => hasDesign && !_completed;

  bool get canPour => _engine != null && !_completed;

  List<PourStamp> get stamps => _engine?.stamps ?? const <PourStamp>[];

  /// Avance del relleno (0..1).
  double get progress => _completed ? 1.0 : (_engine?.progress ?? 0.0);

  /// Precisión del vertido (0..1).
  double get accuracy => _engine?.accuracy ?? 1.0;

  bool get pouring => _pouring;

  /// Punto del vertido (coordenadas unitarias, ya suavizado).
  Offset get jug => _jug;
  Offset get target => _target;

  /// 0 = jarra en reposo … 1 = inclinada sobre la taza.
  double get lean => _lean;

  /// 0..1: intensidad del chorro de leche.
  double get flow => _flow;

  /// Texto de felicitación según la precisión.
  String get verdict {
    final a = accuracy;
    if (a >= 0.9) return '¡Perfecto!';
    if (a >= 0.75) return '¡Muy bien!';
    return '¡Lo lograste!';
  }

  // ───────────── Elegir / reiniciar ─────────────

  static List<bool> _maskOf(Path p) {
    const cs = 2 * _extent / _grid;
    return [
      for (var j = 0; j < _grid; j++)
        for (var i = 0; i < _grid; i++) p.contains(Offset(-_extent + (i + 0.5) * cs, -_extent + (j + 0.5) * cs)),
    ];
  }

  /// Contorno punteado de [src] (la guía que se ve sobre el café).
  static Path _dashed(Path src, {double dash = 0.075, double gap = 0.05}) {
    final out = Path();
    for (final m in src.computeMetrics()) {
      var d = 0.0;
      while (d < m.length) {
        out.addPath(m.extractPath(d, math.min(d + dash, m.length)), Offset.zero);
        d += dash + gap;
      }
    }
    return out;
  }

  void _setup(String design) {
    _pouring = false;
    _lean = 0;
    _flow = 0;
    _milestone = 0;
    _design = design;
    _engine = null;
    _silhouette = null;
    _guide = null;
    _completed = false;
    _score = null;
    newRecord = false;
    if (design.isEmpty) return;
    final sil = LatteArtShapes.silhouette(design);
    if (sil == null) {
      // Diseño que la app aún no sabe dibujar: no se puede guiar el
      // vertido, así que se acepta tal cual (como antes).
      _completed = true;
      return;
    }
    _silhouette = sil;
    _guide = _dashed(sil);
    _engine = LattePourEngine(mask: _maskOf(sil), grid: _grid, extent: _extent);
  }

  /// Elige el diseño a verter. Muestra la silueta guía; NO rellena nada.
  void selectDesign(String design) {
    if (design == _design) return;
    _setup(design);
    _coarse();
  }

  /// Quita el diseño y todo lo vertido.
  void clear() {
    if (_design.isEmpty && !_completed) return;
    _setup('');
    _coarse();
  }

  /// Carga un diseño ya terminado (receta guardada). Conserva el motor
  /// para poder reiniciar el vertido después.
  void loadCompleted(String design) {
    _setup(design);
    if (_engine != null) _completed = true;
    _coarse();
  }

  /// Borra lo vertido y deja la silueta lista para volver a empezar
  /// (sin salir de la etapa ni perder el diseño elegido).
  void restart() {
    final e = _engine;
    if (e == null) return;
    e.reset();
    _completed = false;
    _pouring = false;
    _milestone = 0;
    _score = null;
    newRecord = false;
    resetTick++;
    _coarse();
  }

  // ───────────── Interacción ─────────────

  /// El dedo (o el mouse) toca la taza en [unit].
  void pointerDown(Offset unit) {
    if (!canPour) return;
    _pouring = true;
    _target = unit;
    _jug = unit;
    _engine!.lift();
    _notify();
  }

  void pointerMove(Offset unit) {
    if (!_pouring) return;
    _target = unit;
  }

  void pointerUp() {
    if (!_pouring) return;
    _pouring = false;
    _engine?.lift();
    _notify();
  }

  /// Avanza la simulación [dt] segundos (la llama el escenario en cada
  /// fotograma mientras la etapa de arte está activa).
  void tick(double dt) {
    if (_disposed || dt <= 0) return;
    final e = _engine;
    final before = (_lean, _flow, _jug);

    if (_pouring) _jug = Offset.lerp(_jug, _target, 1 - math.exp(-dt * 16))!;

    _lean += ((_pouring ? 1.0 : 0.0) - _lean) * (1 - math.exp(-dt * (_pouring ? 12 : 7)));
    final onCup = e != null && e.isOnCup(_jug.dx, _jug.dy);
    final wantFlow = _pouring && onCup && _lean > 0.55 ? 1.0 : 0.0;
    _flow += (wantFlow - _flow) * (1 - math.exp(-dt * 14));
    if (!_pouring && _lean < 0.002) _lean = 0;
    if (wantFlow == 0 && _flow < 0.002) _flow = 0;

    var finished = false;
    if (_pouring && e != null && !_completed && _lean > 0.55) {
      e.pour(_jug.dx, _jug.dy, dt);
      _checkMilestones(e.progress);
      if (e.completed) {
        _finish();
        finished = true;
      }
    }

    final moved = _pouring || before != (_lean, _flow, _jug);
    if (moved && !finished) notifyListeners();
  }

  void _checkMilestones(double p) {
    final m = (p * 4).floor();
    if (m > _milestone && m < 4) {
      _milestone = m;
      _buzz(StudioHaptics.select);
    }
  }

  void _finish() {
    _completed = true;
    _pouring = false;
    _engine?.lift();
    doneTick++;
    _score = scoring ? ArtScore.of(accuracy) : null;
    _buzz(StudioHaptics.medium);
    onDone?.call(this);
    _coarse();
  }

  void _buzz(Future<void> Function() haptic) {
    haptic().catchError((Object _) {});
  }

  // ───────────── Avisos ─────────────

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  void _coarse() {
    _notify();
    if (!_disposed) onCoarseChange?.call();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
