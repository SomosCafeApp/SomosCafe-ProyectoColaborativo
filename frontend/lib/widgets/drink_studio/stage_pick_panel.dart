import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/utils/money_format.dart';
import 'option_card.dart';
import 'studio_colors.dart';

/// Panel genérico para elegir varias opciones con precio real
/// (jarabes, endulzantes y adicionales). Cada toque dispara el efecto
/// de caída sobre la taza.
class PickPanel extends StatelessWidget {
  const PickPanel({
    super.key,
    required this.title,
    required this.hint,
    required this.prices,
    required this.selected,
    required this.onToggle,
    required this.icon,
    this.max,
  });

  final String title;
  final String hint;
  final Map<String, double> prices;
  final Set<String> selected;
  final bool Function(String name) onToggle;
  final IconData icon;
  final int? max;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return StagePanel(
      title: title,
      hint: max == null ? hint : '$hint (máx. $max)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final e in prices.entries)
                OptionCard(
                  label: e.key,
                  caption: formatExtra(e.value),
                  selected: selected.contains(e.key),
                  leading: Icon(icon, size: 20, color: StudioColors.accentFor(e.key)),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    if (!onToggle(e.key)) {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(SnackBar(content: Text('Máximo $max opciones en esta etapa')));
                    }
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            selected.isEmpty ? 'Puedes continuar sin elegir ninguna.' : '${selected.length} elegida${selected.length == 1 ? '' : 's'}',
            style: TextStyle(fontSize: 12, color: StudioColors.muted(dark)),
          ),
        ],
      ),
    );
  }
}
