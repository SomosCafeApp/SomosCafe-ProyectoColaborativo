import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/studio_prefs.dart';
import '../../animations/press_scale.dart';
import '../../models/drink_studio_stage.dart';
import '../../providers/drink_studio_provider.dart';
import 'latte_art_shapes.dart';
import 'latte_pour_session.dart';
import 'option_card.dart';
import 'studio_colors.dart';
import 'studio_ui.dart';

/// Arte latte (opcional): el usuario elige un diseño, ve su silueta
/// sobre el café y la rellena él mismo vertiendo la leche con el dedo.
/// Elegir una figura NO la dibuja: solo muestra la guía.
class LatteArtPanel extends StatelessWidget {
  const LatteArtPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<DrinkStudioProvider>();
    final dark = Theme.of(context).brightness == Brightness.dark;
    final designs = s.options!.latteArtDesigns;
    final pour = s.pour;
    final challenge = s.mode == StudioMode.challenge;

    final hint = challenge
        ? (pour.completed ? '¡Reto cumplido! Prueba otro o reinicia para mejorar tu puntaje.' : 'Rellena la silueta del reto con la mayor precisión que puedas.')
        : !pour.hasDesign
        ? 'Es opcional y no cuesta extra. Elige un diseño y rellénalo tú mismo.'
        : pour.completed
            ? '¡Listo! Si quieres otro intento, reinicia el vertido.'
            : 'Mantén presionado y arrastra la jarra sobre la silueta.';

    Widget card({required Widget preview, required String label, required bool selected, required VoidCallback onTap}) => PressScale(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: StudioUi.choice(dark, selected: selected, radius: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 50, width: 50, child: preview),
                const SizedBox(height: 4),
                Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: StudioColors.text(dark))),
              ],
            ),
          ),
        );

    final items = <Widget Function(double)>[
      (w) => SizedBox(
            width: w,
            child: card(
              preview: Icon(Icons.block_rounded, size: 32, color: StudioColors.muted(dark)),
              label: 'Sin arte',
              selected: !pour.hasDesign,
              onTap: () {
                StudioHaptics.select();
                s.selectArt('');
              },
            ),
          ),
      for (final d in designs)
        (w) => SizedBox(
              width: w,
              child: card(
                preview: LatteArtDisc(design: d, size: 50),
                label: d,
                selected: pour.design == d,
                onTap: () {
                  StudioHaptics.select();
                  s.selectArt(d);
                },
              ),
            ),
    ];

    return StagePanel(
      title: '¿Quieres arte latte?',
      hint: hint,
      child: Column(
        children: [
          SegmentedButton<StudioMode>(
            showSelectedIcon: false,
            style: SegmentedButton.styleFrom(selectedBackgroundColor: StudioColors.primary, selectedForegroundColor: Colors.white, foregroundColor: StudioColors.text(dark), visualDensity: VisualDensity.compact),
            segments: const [
              ButtonSegment(value: StudioMode.free, label: Text('Libre'), icon: Icon(Icons.brush_rounded, size: 16)),
              ButtonSegment(value: StudioMode.challenge, label: Text('Desafío'), icon: Icon(Icons.emoji_events_rounded, size: 16)),
            ],
            selected: {s.mode},
            onSelectionChanged: (v) {
              StudioHaptics.select();
              s.setMode(v.first);
            },
          ),
          const SizedBox(height: 10),
          if (challenge)
            _ChallengeCard(studio: s)
          else
            LayoutBuilder(
            builder: (context, box) {
              const gap = 8.0;
              final w = math.max(76.0, (box.maxWidth - gap * (items.length - 1)) / items.length);
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (var i = 0; i < items.length; i++) ...[
                      if (i > 0) const SizedBox(width: gap),
                      items[i](w),
                    ],
                  ],
                ),
              );
            },
          ),
          if (pour.hasDesign) ...[
            const SizedBox(height: 10),
            PourProgressRow(pour: pour),
          ],
        ],
      ),
    );
  }
}

/// Barra de progreso del relleno + botón para reiniciar el vertido.
/// Escucha a la sesión directamente: así se actualiza mientras se
/// vierte sin reconstruir el resto del estudio.
class PourProgressRow extends StatelessWidget {
  const PourProgressRow({super.key, required this.pour});
  final LattePourSession pour;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ListenableBuilder(
      listenable: pour,
      builder: (context, _) {
        final p = pour.progress;
        final percent = (p * 100).round();
        final done = pour.completed;
        final score = pour.score;
        final stars = score == null ? '' : '${'★' * score.stars}${'☆' * (3 - score.stars)} · ${score.points} pts · ';
        final label = done ? '¡Completado! · $stars' 'Precisión ${(pour.accuracy * 100).round()} %' : 'Relleno $percent %';
        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(minHeight: 10, value: p, color: done ? const Color(0xFF3E9B5F) : StudioColors.primary, backgroundColor: StudioColors.soft(dark)),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (done) const Padding(padding: EdgeInsets.only(right: 4), child: Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF3E9B5F))),
                      Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: StudioColors.muted(dark)))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: p > 0 || done
                  ? () {
                      StudioHaptics.light();
                      pour.restart();
                    }
                  : null,
              icon: const Icon(Icons.replay_rounded, size: 18),
              label: const Text('Reiniciar'),
              style: TextButton.styleFrom(foregroundColor: StudioColors.primary),
            ),
          ],
        );
      },
    );
  }
}

/// Reto del modo desafío: diseño a completar, mejor puntaje y otro reto.
class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({required this.studio});
  final DrinkStudioProvider studio;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final design = studio.challengeDesign;
    return ListenableBuilder(
      listenable: StudioPrefs.instance,
      builder: (context, _) {
        final best = StudioPrefs.instance.bestScores[design];
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: StudioColors.soft(dark), borderRadius: BorderRadius.circular(18)),
          child: Row(
            children: [
              if (design.isNotEmpty) LatteArtDisc(design: design, size: 56),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Reto: $design', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: StudioColors.text(dark))),
                    Text(best == null ? 'Aún sin récord' : 'Tu mejor puntaje: $best pts', style: TextStyle(fontSize: 12.5, color: StudioColors.muted(dark))),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  StudioHaptics.select();
                  studio.newChallenge();
                },
                icon: const Icon(Icons.casino_rounded, size: 18),
                label: const Text('Otro reto'),
                style: TextButton.styleFrom(foregroundColor: StudioColors.primary),
              ),
            ],
          ),
        );
      },
    );
  }
}
