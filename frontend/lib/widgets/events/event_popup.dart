import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/app_event.dart';

/// Contenido de la ventana emergente de inicio: la imagen del evento
/// como "afiche" (o una tarjeta con texto si no tiene imagen). Al tocarlo
/// se llama a [onOpenDetails]; la X lo cierra.
class EventPopup extends StatelessWidget {
  final AppEvent event;
  final VoidCallback onOpenDetails;
  final VoidCallback onClose;

  const EventPopup({
    super.key,
    required this.event,
    required this.onOpenDetails,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.68;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: onOpenDetails,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxHeight),
                child: event.hasImage ? _Poster(event: event) : _TextCard(event: event),
              ),
            ),
          ),
          Positioned(
            top: -10,
            right: -6,
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              elevation: 4,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onClose,
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(Icons.close_rounded, size: 20, color: Colors.black87),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Imagen del evento con degradado inferior, nombre y "Toca para ver más".
class _Poster extends StatelessWidget {
  final AppEvent event;

  const _Poster({required this.event});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Image.network(
          event.image,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _TextCard(event: event),
          loadingBuilder: (context, child, progress) => progress == null
              ? child
              : const SizedBox(height: 320, child: Center(child: CircularProgressIndicator())),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withAlpha(190)],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(event.dateRangeText, style: const TextStyle(fontSize: 12, color: Colors.white70)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accentYellow,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Toca para ver más',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.black87),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Versión sin imagen (o si la imagen no cargó).
class _TextCard extends StatelessWidget {
  final AppEvent event;

  const _TextCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.colorScheme.onSurface;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      color: theme.cardTheme.color ?? (isDark ? AppColors.darkSurface : AppColors.lightSurface),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.celebration_rounded, size: 48, color: AppColors.accentYellow),
          const SizedBox(height: 12),
          Text(
            event.name,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textColor),
          ),
          const SizedBox(height: 6),
          Text(event.dateRangeText, style: TextStyle(fontSize: 13, color: subtitleColor)),
          if (event.location.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(event.location, style: TextStyle(fontSize: 13, color: subtitleColor)),
          ],
          const SizedBox(height: 16),
          Text(
            'Toca para ver más',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
