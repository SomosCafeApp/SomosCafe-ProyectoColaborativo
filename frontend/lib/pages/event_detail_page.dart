import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../models/app_event.dart';
import '../widgets/events/event_hero.dart';
import '../widgets/events/event_info_tile.dart';
import '../widgets/profile/profile_sub_page_header.dart';

/// Información completa del evento (se abre al tocar el pop-up).
class EventDetailPage extends StatelessWidget {
  final AppEvent event;

  const EventDetailPage({super.key, required this.event});

  static const _months = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
  ];

  String _longDate(DateTime d) => '${d.day} de ${_months[d.month - 1]} de ${d.year}';

  String get _dateText {
    final s = event.startDate;
    final e = event.endDate;
    final sameDay = s.year == e.year && s.month == e.month && s.day == e.day;
    return sameDay ? _longDate(s) : 'Del ${_longDate(s)}\nal ${_longDate(e)}';
  }

  /// "Empieza mañana", "Termina hoy"... según en qué momento está.
  String? get _dateNote {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (event.hasEnded) return null;

    if (!event.hasStarted) {
      final start = DateTime(event.startDate.year, event.startDate.month, event.startDate.day);
      final days = start.difference(today).inDays;
      if (days <= 0) return 'Empieza hoy';
      if (days == 1) return 'Empieza mañana';
      return 'Empieza en $days días';
    }

    final end = DateTime(event.endDate.year, event.endDate.month, event.endDate.day);
    final days = end.difference(today).inDays;
    if (days <= 0) return 'Termina hoy';
    if (days == 1) return 'Termina mañana';
    return 'Termina en $days días';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.colorScheme.onSurface;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          const ProfileSubPageHeader(
            title: 'Evento',
            subtitle: 'Todos los detalles',
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EventHero(event: event),
                  const SizedBox(height: 22),
                  Text(
                    event.name,
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, height: 1.15, color: textColor),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.accentYellow,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  if (event.description.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(
                      event.description,
                      style: TextStyle(fontSize: 15, height: 1.6, color: subtitleColor),
                    ),
                  ],
                  const SizedBox(height: 24),
                  EventInfoTile(
                    icon: Icons.event_rounded,
                    iconColor: AppColors.primary,
                    iconBackground: isDark ? const Color(0xFF33261D) : AppColors.catWarm,
                    label: 'Cuándo',
                    value: _dateText,
                    note: _dateNote,
                  ),
                  if (event.location.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    EventInfoTile(
                      icon: Icons.location_on_rounded,
                      iconColor: const Color(0xFF0288D1),
                      iconBackground: isDark ? const Color(0xFF1E2B35) : AppColors.catCold,
                      label: 'Dónde',
                      value: event.location,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
