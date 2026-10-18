import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Selectores de fecha con el estilo de la app (café moca, bordes
/// redondeados, claro y oscuro). Úsalos en lugar de showDatePicker /
/// showDateRangePicker para que todos los calendarios se vean igual.

Widget _themed(BuildContext context, Widget? child) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
  final subtle = isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle;
  final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
  final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

  Color? dayText(Set<WidgetState> states) {
    if (states.contains(WidgetState.selected)) return Colors.white;
    if (states.contains(WidgetState.disabled)) return textSecondary.withValues(alpha: 0.4);
    return textPrimary;
  }

  final pickerTheme = DatePickerThemeData(
    backgroundColor: surface,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    elevation: 0,

    // Encabezado (la fecha elegida) en el café de la app.
    headerBackgroundColor: AppColors.primary,
    headerForegroundColor: Colors.white,
    headerHelpStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.4),
    headerHeadlineStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),

    // Días.
    dayStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
    dayForegroundColor: WidgetStateProperty.resolveWith(dayText),
    dayBackgroundColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected) ? AppColors.primary : Colors.transparent,
    ),
    dayOverlayColor: WidgetStatePropertyAll(AppColors.primary.withValues(alpha: 0.12)),
    todayForegroundColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected) ? Colors.white : AppColors.primary,
    ),
    todayBackgroundColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected) ? AppColors.primary : Colors.transparent,
    ),
    todayBorder: const BorderSide(color: AppColors.primary, width: 1.4),
    weekdayStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textSecondary),
    yearForegroundColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected) ? Colors.white : textPrimary,
    ),
    yearBackgroundColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected) ? AppColors.primary : Colors.transparent,
    ),

    // Rango (eventos y promociones).
    rangePickerBackgroundColor: surface,
    rangePickerSurfaceTintColor: Colors.transparent,
    rangePickerHeaderBackgroundColor: AppColors.primary,
    rangePickerHeaderForegroundColor: Colors.white,
    rangePickerHeaderHelpStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
    rangePickerHeaderHeadlineStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
    rangeSelectionBackgroundColor: AppColors.primary.withValues(alpha: isDark ? 0.28 : 0.16),
    rangeSelectionOverlayColor: WidgetStatePropertyAll(AppColors.primary.withValues(alpha: 0.10)),

    dividerColor: subtle,
    cancelButtonStyle: TextButton.styleFrom(
      foregroundColor: textSecondary,
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),
    confirmButtonStyle: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      textStyle: const TextStyle(fontWeight: FontWeight.w800),
    ),
  );

  return Theme(
    data: theme.copyWith(
      colorScheme: theme.colorScheme.copyWith(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        surface: surface,
        onSurface: textPrimary,
      ),
      datePickerTheme: pickerTheme,
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
      ),
    ),
    child: child!,
  );
}

/// Elegir un rango de fechas (inicio y fin) con el estilo de la app.
Future<DateTimeRange?> showAppDateRangePicker(
  BuildContext context, {
  required DateTime firstDate,
  required DateTime lastDate,
  DateTimeRange? initialDateRange,
  String? helpText,
}) {
  return showDateRangePicker(
    context: context,
    firstDate: firstDate,
    lastDate: lastDate,
    initialDateRange: initialDateRange,
    helpText: helpText,
    saveText: 'Listo',
    cancelText: 'Cancelar',
    confirmText: 'Listo',
    initialEntryMode: DatePickerEntryMode.calendarOnly,
    builder: _themed,
  );
}

/// Elegir una sola fecha con el estilo de la app.
Future<DateTime?> showAppDatePicker(
  BuildContext context, {
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  String? helpText,
}) {
  return showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
    helpText: helpText,
    cancelText: 'Cancelar',
    confirmText: 'Aceptar',
    initialEntryMode: DatePickerEntryMode.calendarOnly,
    builder: _themed,
  );
}
