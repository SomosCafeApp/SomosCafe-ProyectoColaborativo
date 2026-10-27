import 'dart:math' as math;

/// Mancha de leche depositada sobre la superficie del café.
/// Coordenadas unitarias (x, y de -1 a 1, y hacia abajo): las mismas
/// en las que se dibujan los diseños de `LatteArtShapes`.
class PourStamp {
  PourStamp(this.x, this.y, this.r, this.onTarget);

  final double x;
  final double y;

  /// Radio de la mancha (crece mientras se mantiene el vertido quieto).
  double r;

  /// false = cayó fuera de la silueta (se ve como un pequeño derrame).
  final bool onTarget;
}

/// Lógica pura (sin Flutter) del vertido interactivo del arte latte.
///
/// Se le entrega una máscara de la silueta (`grid × grid` celdas sobre
/// el cuadrado [-extent, extent]) y va registrando por dónde cae la
/// leche. De ahí salen el progreso del relleno, la precisión y si el
/// diseño ya quedó terminado. Los errores pequeños no la interrumpen:
/// un derrame solo baja la precisión, nunca detiene el vertido.
class LattePourEngine {
  LattePourEngine({
    required this.mask,
    this.grid = 32,
    this.extent = 1.2,
    this.brush = 0.15,
    this.maxBrush = 0.25,
    this.tolerance = 0.14,
    this.reach = 1.15,
    this.completeAt = 0.92,
    this.maxStamps = 3000,
    this.maxSpills = 60,
  })  : assert(mask.length == grid * grid, 'La máscara debe ser grid × grid'),
        _covered = List<bool>.filled(grid * grid, false),
        _saturation = List<int>.filled(grid * grid, 0),
        _near = List<bool>.filled(grid * grid, false),
        targetCells = mask.where((m) => m).length {
    _buildNear();
  }

  /// Celdas que pertenecen a la silueta.
  final List<bool> mask;
  final int grid;
  final double extent;

  /// Radio base de la mancha y el máximo al mantener el vertido quieto.
  final double brush;
  final double maxBrush;

  /// Holgura (unidades) alrededor de la silueta que aún cuenta como
  /// "bien vertido": permite pequeños errores de pulso.
  final double tolerance;

  /// Más allá de este radio la leche cae fuera de la taza.
  final double reach;

  /// Fracción de la silueta que da el diseño por terminado.
  final double completeAt;
  final int maxStamps;
  final int maxSpills;

  final int targetCells;
  final List<PourStamp> stamps = [];

  final List<bool> _covered;
  final List<int> _saturation;
  final List<bool> _near;

  int _coveredTarget = 0;
  int _attempts = 0;
  int _good = 0;
  int _spills = 0;
  double _dwell = 0;
  bool _hasLast = false;
  double _lx = 0;
  double _ly = 0;
  PourStamp? _lastStamp;
  bool _completed = false;

  double get _cell => 2 * extent / grid;

  /// Avance del relleno de la silueta (0..1).
  double get progress => targetCells == 0 ? 0 : (_coveredTarget / targetCells).clamp(0.0, 1.0).toDouble();

  bool get completed => _completed;

  /// Qué tanta de la leche vertida cayó dentro de la silueta (0..1).
  double get accuracy => _attempts == 0 ? 1 : _good / _attempts;

  int get spillCount => _spills;

  int _idx(int i, int j) => j * grid + i;

  int _cellOf(double v) => ((v + extent) / _cell).floor();

  void _buildNear() {
    final rad = (tolerance / _cell).ceil();
    for (var j = 0; j < grid; j++) {
      for (var i = 0; i < grid; i++) {
        if (!mask[_idx(i, j)]) continue;
        for (var dj = -rad; dj <= rad; dj++) {
          for (var di = -rad; di <= rad; di++) {
            final ni = i + di, nj = j + dj;
            if (ni < 0 || nj < 0 || ni >= grid || nj >= grid) continue;
            if (di * di + dj * dj <= rad * rad) _near[_idx(ni, nj)] = true;
          }
        }
      }
    }
  }

  /// ¿El punto está sobre la silueta o a menos de la holgura de ella?
  bool isNearTarget(double x, double y) {
    final i = _cellOf(x), j = _cellOf(y);
    if (i < 0 || j < 0 || i >= grid || j >= grid) return false;
    return _near[_idx(i, j)];
  }

  /// ¿El punto cae dentro de la taza?
  bool isOnCup(double x, double y) => x * x + y * y <= reach * reach;

  void _mark(double x, double y, double r) {
    final i0 = _cellOf(x - r).clamp(0, grid - 1).toInt();
    final i1 = _cellOf(x + r).clamp(0, grid - 1).toInt();
    final j0 = _cellOf(y - r).clamp(0, grid - 1).toInt();
    final j1 = _cellOf(y + r).clamp(0, grid - 1).toInt();
    for (var j = j0; j <= j1; j++) {
      final cy = -extent + (j + 0.5) * _cell;
      for (var i = i0; i <= i1; i++) {
        final cx = -extent + (i + 0.5) * _cell;
        final dx = cx - x, dy = cy - y;
        if (dx * dx + dy * dy > r * r) continue;
        final k = _idx(i, j);
        if (_covered[k]) continue;
        _covered[k] = true;
        if (mask[k]) _coveredTarget++;
      }
    }
  }

  void _addStamp(double x, double y, double r, bool on) {
    if (stamps.length >= maxStamps) return;
    final i = _cellOf(x), j = _cellOf(y);
    final inGrid = i >= 0 && j >= 0 && i < grid && j < grid;
    // Una celda ya saturada de manchas no necesita más (evita miles de
    // círculos al repasar la misma zona).
    if (inGrid && on) {
      final k = _idx(i, j);
      if (_saturation[k] >= 4) {
        return;
      }
      _saturation[k]++;
    }
    final stamp = PourStamp(x, y, r, on);
    stamps.add(stamp);
    _lastStamp = stamp;
    if (!on) {
      _spills++;
      if (_spills > maxSpills) {
        final old = stamps.indexWhere((s) => !s.onTarget);
        if (old >= 0) {
          stamps.removeAt(old);
          _spills--;
        }
      }
    }
  }

  void _deposit(double x, double y) {
    final on = isNearTarget(x, y);
    _attempts++;
    if (on) _good++;
    _addStamp(x, y, brush, on);
    _mark(x, y, brush);
    _lx = x;
    _ly = y;
    _hasLast = true;
  }

  /// Levanta la jarra: el siguiente vertido no une con el anterior.
  void lift() {
    _hasLast = false;
    _dwell = 0;
    _lastStamp = null;
  }

  /// Vierte leche en ([x], [y]) durante [dt] segundos. Moverse deja un
  /// trazo continuo; quedarse quieto hace crecer la mancha. Devuelve
  /// true si en este paso la leche cayó dentro de la taza.
  bool pour(double x, double y, double dt) {
    if (_completed || targetCells == 0) return false;
    if (!isOnCup(x, y)) {
      lift();
      return false;
    }

    if (!_hasLast) {
      _deposit(x, y);
    } else {
      final dx = x - _lx, dy = y - _ly;
      final d = math.sqrt(dx * dx + dy * dy);
      if (d < brush * 0.25) {
        _dwell += dt;
        _growLast(x, y);
      } else {
        _dwell = 0;
        final n = (d / (brush * 0.5)).ceil();
        final startX = _lx, startY = _ly;
        for (var k = 1; k <= n; k++) {
          _deposit(startX + dx * k / n, startY + dy * k / n);
        }
      }
    }

    if (progress >= completeAt) _completed = true;
    return true;
  }

  void _growLast(double x, double y) {
    final last = _lastStamp;
    if (last == null) {
      _deposit(x, y);
      return;
    }
    final grown = brush + (maxBrush - brush) * math.min(1.0, _dwell);
    final dx = last.x - x, dy = last.y - y;
    if (dx * dx + dy * dy > brush * brush * 0.36) {
      // La última mancha quedó atrás (zona ya saturada): solo se cubre.
      _mark(x, y, grown);
      return;
    }
    if (grown > last.r) {
      last.r = grown;
      _mark(last.x, last.y, grown);
    }
  }

  /// Borra lo vertido (el diseño elegido se conserva).
  void reset() {
    stamps.clear();
    for (var i = 0; i < _covered.length; i++) {
      _covered[i] = false;
      _saturation[i] = 0;
    }
    _coveredTarget = 0;
    _attempts = 0;
    _good = 0;
    _spills = 0;
    _completed = false;
    lift();
  }
}
