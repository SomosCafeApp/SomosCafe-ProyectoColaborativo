import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/app_event.dart';

/// Tarjeta de un evento en el panel admin. Interruptor para activarlo
/// (el activo sale como pop-up al abrir la app; solo uno a la vez),
/// editar y eliminar.
class AdminEventCard extends StatelessWidget {
  final AppEvent event;
  final bool isBusy;
  final ValueChanged<bool> onToggleActive;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AdminEventCard({
    super.key,
    required this.event,
    required this.isBusy,
    required this.onToggleActive,
    required this.onEdit,
    required this.onDelete,
  });

  Color get _statusColor {
    switch (event.status) {
      case AppEventStatus.active:
        return const Color(0xFF4CAF50);
      case AppEventStatus.inactive:
        return const Color(0xFF9E9E9E);
      case AppEventStatus.ended:
        return const Color(0xFFE53935);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardColor = theme.cardTheme.color ?? (isDark ? AppColors.darkSurface : AppColors.lightSurface);
    final textColor = theme.colorScheme.onSurface;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final fill = isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle;
    final isActiveNow = event.status == AppEventStatus.active;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: isActiveNow ? Border.all(color: AppColors.accentYellow, width: 2) : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(isDark ? 40 : 8), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 72,
                  height: 72,
                  color: fill,
                  child: event.hasImage
                      ? Image.network(
                          event.image,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Icon(Icons.celebration_outlined, color: subtitleColor),
                        )
                      : Icon(Icons.celebration_outlined, color: subtitleColor),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    const SizedBox(height: 4),
                    Text(event.dateRangeText, style: TextStyle(fontSize: 12, color: subtitleColor)),
                    if (event.location.isNotEmpty)
                      Text(event.location, style: TextStyle(fontSize: 12, color: subtitleColor)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _statusColor.withAlpha(isDark ? 40 : 25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        event.status.label,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _statusColor),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 22),
          if (isBusy)
            const Padding(
              padding: EdgeInsets.all(4),
              child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            Row(
              children: [
                Switch(
                  value: event.isActive && !event.hasEnded,
                  activeThumbColor: AppColors.primary,
                  // Un evento que ya terminó no se puede activar.
                  onChanged: event.hasEnded ? null : onToggleActive,
                ),
                Text(isActiveNow ? 'Activo' : 'Activar', style: TextStyle(fontSize: 12, color: subtitleColor)),
                const Spacer(),
                IconButton(
                  tooltip: 'Editar',
                  icon: Icon(Icons.edit_outlined, color: subtitleColor),
                  onPressed: onEdit,
                ),
                IconButton(
                  tooltip: 'Eliminar',
                  icon: const Icon(Icons.delete_outline, color: Color(0xFFE53935)),
                  onPressed: onDelete,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
