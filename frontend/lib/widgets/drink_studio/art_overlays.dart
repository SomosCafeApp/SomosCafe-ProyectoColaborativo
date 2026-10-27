import 'dart:async';

import 'package:flutter/material.dart';

import 'latte_pour_session.dart';
import 'studio_colors.dart';

/// Pista breve sobre el escenario: aparece cuando hay una silueta
/// elegida y el usuario aún no empezó a verter; desaparece al tocar.
class ArtCoachMark extends StatelessWidget {
  const ArtCoachMark({super.key, required this.pour});
  final LattePourSession pour;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return IgnorePointer(
      child: ListenableBuilder(
        listenable: pour,
        builder: (context, _) {
          final show = pour.pending && pour.progress == 0 && !pour.pouring;
          return AnimatedOpacity(
            opacity: show ? 1 : 0,
            duration: const Duration(milliseconds: 250),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: StudioColors.panel(dark).withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: StudioColors.primary.withValues(alpha: 0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.touch_app_rounded, size: 18, color: StudioColors.primary),
                  const SizedBox(width: 6),
                  Text('Mantén presionado y arrastra', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: StudioColors.text(dark))),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Aviso de satisfacción al terminar el diseño: aparece con un rebote
/// ~2 s y se retira solo (no bloquea seguir jugando).
class ArtDoneBanner extends StatefulWidget {
  const ArtDoneBanner({super.key, required this.pour});
  final LattePourSession pour;

  @override
  State<ArtDoneBanner> createState() => _ArtDoneBannerState();
}

class _ArtDoneBannerState extends State<ArtDoneBanner> {
  static const Duration _visibleFor = Duration(milliseconds: 2200);
  bool _visible = false;
  int _seen = 0;
  String _text = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _seen = widget.pour.doneTick;
    widget.pour.addListener(_onPour);
  }

  @override
  void didUpdateWidget(ArtDoneBanner old) {
    super.didUpdateWidget(old);
    if (old.pour != widget.pour) {
      old.pour.removeListener(_onPour);
      _seen = widget.pour.doneTick;
      widget.pour.addListener(_onPour);
    }
  }

  void _onPour() {
    if (widget.pour.doneTick == _seen) return;
    _seen = widget.pour.doneTick;
    if (!widget.pour.completed || !mounted) return;
    setState(() {
      _visible = true;
      final score = widget.pour.score;
      _text = score == null
          ? '¡Arte latte listo! ${widget.pour.verdict}'
          : '¡Reto superado! ${'★' * score.stars}${'☆' * (3 - score.stars)} · ${score.points} pts${widget.pour.newRecord ? ' · ¡Récord!' : ''}';
    });
    _timer?.cancel();
    _timer = Timer(_visibleFor, () {
      if (mounted) setState(() => _visible = false);
    });
  }

  @override
  void dispose() {
    widget.pour.removeListener(_onPour);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: _visible ? 1 : 0,
        duration: const Duration(milliseconds: 280),
        child: AnimatedScale(
          scale: _visible ? 1 : 0.6,
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutBack,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: StudioColors.panel(dark),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: StudioColors.primary, width: 1.6),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 12, offset: const Offset(0, 5))],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome_rounded, size: 20, color: StudioColors.caramel),
                const SizedBox(width: 8),
                Text(_text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: StudioColors.text(dark))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
