import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/drink_studio_provider.dart';
import 'cup_stage.dart';
import 'studio_colors.dart';
import 'summary_actions.dart';
import 'summary_details.dart';

/// Presentación final, dentro de la misma pantalla: el vaso se cierra
/// con su tapa y se muestran datos, precio total y acciones.
class SummaryOverlay extends StatelessWidget {
  const SummaryOverlay({super.key, required this.onAdd, required this.onSave});
  final VoidCallback onAdd;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<DrinkStudioProvider>();
    final dark = Theme.of(context).brightness == Brightness.dark;
    final description = s.product.description.trim();

    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 12, 0),
              child: Row(
                children: [
                  IconButton(tooltip: 'Volver a editar', onPressed: s.adding ? null : s.closeSummary, icon: Icon(Icons.arrow_back_rounded, color: StudioColors.text(dark))),
                  Expanded(child: Text('Tu creación está lista', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: StudioColors.text(dark)))),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                children: [
                  SizedBox(height: 270, child: CupStage(snapshot: s.snapshot, lidOn: true)),
                  Text(s.product.name, textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: StudioColors.text(dark))),
                  const SizedBox(height: 2),
                  const Text('Creación personalizada', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700, color: StudioColors.primary)),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(description, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, height: 1.35, color: StudioColors.muted(dark))),
                  ],
                  const SizedBox(height: 16),
                  SummaryDetails(studio: s),
                  const SizedBox(height: 14),
                  SummaryPrice(studio: s),
                  const SizedBox(height: 16),
                  SummaryActions(studio: s, onAdd: onAdd, onSave: onSave),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
