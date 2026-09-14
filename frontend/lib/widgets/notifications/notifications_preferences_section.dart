import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'notification_schedule_card.dart';

class NotificationsPreferencesSection extends StatelessWidget {
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  final ValueChanged<TimeOfDay> onStartTimeChanged;
  final ValueChanged<TimeOfDay> onEndTimeChanged;

  const NotificationsPreferencesSection({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.onStartTimeChanged,
    required this.onEndTimeChanged,
  });

  Future<void> _selectTime(
    BuildContext context,
    bool isStart,
  ) async {
    final theme = Theme.of(context);

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? startTime : endTime,
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: theme.colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (isStart) {
        onStartTimeChanged(picked);
      } else {
        onEndTimeChanged(picked);
      }
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0
        ? 12
        : time.hourOfPeriod;

    final minute = time.minute.toString().padLeft(2, '0');

    final period = time.period == DayPeriod.am
        ? 'a.m.'
        : 'p.m.';

    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;

    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;

    final subtitleColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    final timeBoxBorder = isDark
        ? AppColors.darkSurfaceSubtle
        : AppColors.lightSurfaceSubtle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferencias Adicionales',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),

        const SizedBox(height: 12),

        NotificationScheduleCard(
          startTime: _formatTimeOfDay(startTime),
          endTime: _formatTimeOfDay(endTime),
          onSelectStartTime: () {
            _selectTime(context, true);
          },
          onSelectEndTime: () {
            _selectTime(context, false);
          },
          cardColor: cardColor,
          textColor: textColor,
          subtitleColor: subtitleColor,
          borderColor: timeBoxBorder,
        ),
      ],
    );
  }
}