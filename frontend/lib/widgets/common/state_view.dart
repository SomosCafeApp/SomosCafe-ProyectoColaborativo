import 'package:flutter/material.dart';

import '../../animations/animations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_tokens.dart';

enum StateKind { empty, noResults, offline, error, success }

/// Estado de pantalla completo con el lenguaje visual de SOMOS CAFÉ:
/// círculo suave + icono + vapor, título, mensaje y acción opcional.
/// Un único componente para carritos vacíos, búsquedas sin resultados,
/// falta de conexión, errores de carga y operaciones exitosas.
class StateView extends StatelessWidget {
  const StateView({
    super.key,
    required this.kind,
    this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.icon,
  });

  final StateKind kind;
  final String? title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? icon;

  /// Detecta un error de red por su texto (los servicios lanzan
  /// excepciones con mensajes en español).
  static StateKind kindForError(Object? error) {
    final text = (error ?? '').toString().toLowerCase();
    final offline = text.contains('conexi') || text.contains('socket') || text.contains('internet') || text.contains('timeout') || text.contains('network');
    return offline ? StateKind.offline : StateKind.error;
  }

  IconData get _icon => icon ??
      switch (kind) {
        StateKind.empty => Icons.coffee_outlined,
        StateKind.noResults => Icons.search_off_rounded,
        StateKind.offline => Icons.wifi_off_rounded,
        StateKind.error => Icons.error_outline_rounded,
        StateKind.success => Icons.check_rounded,
      };

  String get _title =>
      title ??
      switch (kind) {
        StateKind.empty => 'Aquí no hay nada todavía',
        StateKind.noResults => 'Sin resultados',
        StateKind.offline => 'Sin conexión',
        StateKind.error => 'Algo salió mal',
        StateKind.success => '¡Listo!',
      };

  String get _message =>
      message ??
      switch (kind) {
        StateKind.empty => 'Cuando tengas algo, aparecerá aquí.',
        StateKind.noResults => 'Prueba con otras palabras o revisa la ortografía.',
        StateKind.offline => 'Revisa tu internet e inténtalo de nuevo.',
        StateKind.error => 'No pudimos cargar la información. Inténtalo otra vez.',
        StateKind.success => 'La operación se completó correctamente.',
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final accent = switch (kind) {
      StateKind.error => theme.colorScheme.error,
      StateKind.success => const Color(0xFF3E8E5A),
      _ => dark ? const Color(0xFFD4BBA5) : theme.colorScheme.primary,
    };
    final circle = dark ? AppColors.darkSurfaceSubtle : accent.withValues(alpha: 0.14);
    final secondary = dark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return SoftFadeIn(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.xl),
          child: Semantics(
            container: true,
            label: '$_title. $_message',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 96,
                  height: 118,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: circle),
                        child: Icon(_icon, size: 40, color: accent),
                      ),
                      if (kind == StateKind.empty || kind == StateKind.success)
                        Positioned(top: 0, child: CoffeeSteam(size: 36, color: accent)),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpace.lg),
                Text(_title, textAlign: TextAlign.center, style: AppText.title(context)),
                const SizedBox(height: AppSpace.sm),
                Text(_message, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: secondary, height: 1.4)),
                if (onAction != null && actionLabel != null) ...[
                  const SizedBox(height: AppSpace.xl),
                  PressScale(
                    child: FilledButton(
                      onPressed: onAction,
                      style: FilledButton.styleFrom(minimumSize: const Size(160, AppSizes.minTap)),
                      child: Text(actionLabel!),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
