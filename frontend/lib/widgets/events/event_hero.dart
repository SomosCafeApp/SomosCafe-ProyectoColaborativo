import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/app_event.dart';

/// Imagen principal del evento con sombra, esquinas redondeadas y una
/// etiqueta de estado ("En curso", "Próximamente", "Finalizado").
/// Sin imagen, muestra un banner con degradado del color de la marca.
class EventHero extends StatelessWidget {
  final AppEvent event;

  const EventHero({super.key, required this.event});

  ({String label, Color color}) get _phase {
    if (event.hasEnded) return (label: 'Finalizado', color: const Color(0xFF9E9E9E));
    if (!event.hasStarted) return (label: 'Próximamente', color: const Color(0xFF2196F3));
    return (label: 'En curso', color: const Color(0xFF4CAF50));
  }

  @override
  Widget build(BuildContext context) {
    final phase = _phase;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(45), blurRadius: 18, offset: const Offset(0, 8)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            event.hasImage
                ? Image.network(
                    event.image,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const _Banner(),
                    loadingBuilder: (context, child, progress) => progress == null
                        ? child
                        : const SizedBox(height: 240, child: Center(child: CircularProgressIndicator())),
                  )
                : const _Banner(),
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: phase.color,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(60), blurRadius: 6)],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.circle, size: 8, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      phase.label,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primary.withAlpha(170)],
        ),
      ),
      child: const Icon(Icons.celebration_rounded, size: 72, color: Colors.white),
    );
  }
}
