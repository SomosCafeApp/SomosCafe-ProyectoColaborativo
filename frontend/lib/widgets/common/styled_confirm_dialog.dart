import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

const Color _dangerColor = Color(0xFFE53935);

/// Colores y textos compartidos por todos los diálogos de confirmación,
/// tomados del diálogo de cerrar sesión.
class _DialogPalette {
  _DialogPalette(BuildContext context, {required bool destructive})
      : theme = Theme.of(context),
        isDark = Theme.of(context).brightness == Brightness.dark,
        accent = destructive ? _dangerColor : AppColors.primary {
    textColor = theme.colorScheme.onSurface;
    subtitleColor = isDark ? const Color(0xFFB0A49E) : const Color(0xFF757575);
    iconBackground = destructive
        ? (isDark ? const Color(0xFF381C1C) : const Color(0xFFFFEBEE))
        : (isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle);
    borderColor = isDark ? Colors.white24 : Colors.grey.shade300;
  }

  final ThemeData theme;
  final bool isDark;
  final Color accent;
  late final Color textColor;
  late final Color subtitleColor;
  late final Color iconBackground;
  late final Color borderColor;
}

class _DialogShell extends StatelessWidget {
  const _DialogShell({
    required this.palette,
    required this.icon,
    required this.title,
    required this.message,
    required this.actions,
  });

  final _DialogPalette palette;
  final IconData icon;
  final String title;
  final String message;
  final Widget actions;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: palette.theme.cardTheme.color,
      contentPadding: const EdgeInsets.all(24),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: palette.iconBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: palette.accent, size: 32),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: palette.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: palette.subtitleColor,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            actions,
          ],
        ),
      ),
    );
  }
}

Widget _cancelButton(_DialogPalette p, String label, VoidCallback onPressed) {
  return TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: p.borderColor),
      ),
    ),
    child: Text(
      label,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: p.textColor,
      ),
    ),
  );
}

Widget _filledButton(Color color, String label, VoidCallback onPressed) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    child: Text(
      label,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    ),
  );
}

/// Diálogo de confirmación con el estilo de "Cerrar sesión".
/// Devuelve true solo si el usuario pulsa el botón de confirmación.
/// [destructive] usa rojo; si es false usa el color primario de la marca.
Future<bool> showStyledConfirmDialog(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = 'Cancelar',
  bool destructive = true,
}) async {
  final p = _DialogPalette(context, destructive: destructive);

  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => _DialogShell(
      palette: p,
      icon: icon,
      title: title,
      message: message,
      actions: Row(
        children: [
          Expanded(child: _cancelButton(p, cancelLabel, () => Navigator.pop(ctx, false))),
          const SizedBox(width: 12),
          Expanded(child: _filledButton(p.accent, confirmLabel, () => Navigator.pop(ctx, true))),
        ],
      ),
    ),
  );

  return result == true;
}

/// Opción extra para diálogos con tres salidas (p. ej. "Solo ocultar").
class StyledDialogChoice<T> {
  const StyledDialogChoice({
    required this.value,
    required this.label,
    this.destructive = false,
  });

  final T value;
  final String label;
  final bool destructive;
}

/// Diálogo de varias opciones con el mismo estilo. Las opciones se apilan
/// en vertical; el botón de cancelar siempre va al final y devuelve
/// [cancelValue].
Future<T> showStyledChoiceDialog<T>(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String message,
  required List<StyledDialogChoice<T>> choices,
  required T cancelValue,
  String cancelLabel = 'Cancelar',
}) async {
  final p = _DialogPalette(context, destructive: true);

  final result = await showDialog<T>(
    context: context,
    builder: (ctx) => _DialogShell(
      palette: p,
      icon: icon,
      title: title,
      message: message,
      actions: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final c in choices) ...[
            _filledButton(
              c.destructive ? _dangerColor : AppColors.primary,
              c.label,
              () => Navigator.pop(ctx, c.value),
            ),
            const SizedBox(height: 10),
          ],
          _cancelButton(p, cancelLabel, () => Navigator.pop(ctx, cancelValue)),
        ],
      ),
    ),
  );

  return result ?? cancelValue;
}
