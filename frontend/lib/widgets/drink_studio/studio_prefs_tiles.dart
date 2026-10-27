import 'package:flutter/material.dart';

import '../../core/utils/studio_prefs.dart';
import 'studio_colors.dart';

/// Interruptores del estudio de bebidas (vibración, efectos y
/// animaciones). Los usa la hoja del estudio; Ajustes tiene su propia
/// versión con el estilo de esa pantalla.
class StudioPrefsSwitches extends StatelessWidget {
  const StudioPrefsSwitches({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final prefs = StudioPrefs.instance;
    return ListenableBuilder(
      listenable: prefs,
      builder: (context, _) {
        Widget tile(IconData icon, String title, String subtitle, bool value, ValueChanged<bool> onChanged) => SwitchListTile(
              value: value,
              onChanged: onChanged,
              activeThumbColor: StudioColors.primary,
              secondary: Icon(icon, color: StudioColors.primary),
              title: Text(title, style: TextStyle(fontWeight: FontWeight.w800, color: StudioColors.text(dark))),
              subtitle: Text(subtitle, style: TextStyle(fontSize: 12.5, color: StudioColors.muted(dark))),
            );
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            tile(Icons.vibration_rounded, 'Vibración', 'Respuesta táctil al elegir y al verter', prefs.haptics, prefs.setHaptics),
            tile(Icons.auto_awesome_rounded, 'Efectos', 'Destellos, chorros, nieve y fuego', prefs.effects, prefs.setEffects),
            tile(Icons.animation_rounded, 'Animaciones', 'Transiciones, vapor y movimiento de cámara', prefs.animations, prefs.setAnimations),
          ],
        );
      },
    );
  }
}

/// Hoja inferior con los ajustes del estudio.
Future<void> showStudioSettingsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => const SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: StudioPrefsSwitches(),
      ),
    ),
  );
}
