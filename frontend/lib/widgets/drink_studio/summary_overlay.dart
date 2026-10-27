import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/cup_snapshot.dart';
import '../../providers/drink_studio_provider.dart';
import 'cup_stage.dart';
import 'stage_pairing_panel.dart';
import 'studio_colors.dart';
import 'summary_actions.dart';
import 'summary_details.dart';

/// Resultado final: la bebida terminada (desde arriba, o de lado con su
/// tapa), sus datos, el precio total y las acciones. Los
/// acompañamientos se eligen aquí, antes de agregar al carrito.
class SummaryOverlay extends StatefulWidget {
  const SummaryOverlay({super.key, required this.onAdd, required this.onSave});
  final VoidCallback onAdd;
  final VoidCallback onSave;

  @override
  State<SummaryOverlay> createState() => _SummaryOverlayState();
}

class _SummaryOverlayState extends State<SummaryOverlay> {
  bool? _top;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<DrinkStudioProvider>();
    final dark = Theme.of(context).brightness == Brightness.dark;
    final description = s.product.description.trim();
    // Por defecto: desde arriba si hay arte o toppings que lucir.
    final top = _top ?? (s.latteArt.isNotEmpty || s.toppings.isNotEmpty);

    Widget chip(String label, IconData icon, bool selected, VoidCallback onTap) => ChoiceChip(
          avatar: Icon(icon, size: 16, color: selected ? Colors.white : StudioColors.primary),
          label: Text(label),
          selected: selected,
          showCheckmark: false,
          selectedColor: StudioColors.primary,
          labelStyle: TextStyle(fontWeight: FontWeight.w700, color: selected ? Colors.white : StudioColors.text(dark)),
          onSelected: (_) => onTap(),
        );

    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 12, 0),
              child: Row(
                children: [
                  IconButton(tooltip: 'Volver a editar', onPressed: s.adding ? null : s.back, icon: Icon(Icons.arrow_back_rounded, color: StudioColors.text(dark))),
                  Expanded(child: Text('Tu creación está lista', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: StudioColors.text(dark)))),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                children: [
                  SizedBox(
                    height: 290,
                    child: CupStage(snapshot: s.snapshot, view: top ? CupView.top : CupView.side, lidOn: !top, ambient: false),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      chip('Desde arriba', Icons.visibility_outlined, top, () => setState(() => _top = true)),
                      const SizedBox(width: 8),
                      chip('De lado', Icons.local_cafe_outlined, !top, () => setState(() => _top = false)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(s.product.name, textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: StudioColors.text(dark))),
                  const SizedBox(height: 2),
                  const Text('Creación personalizada', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700, color: StudioColors.primary)),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(description, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, height: 1.35, color: StudioColors.muted(dark))),
                  ],
                  const SizedBox(height: 16),
                  SummaryDetails(studio: s),
                  if (s.availablePairings.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const PairingPanel(),
                  ],
                  const SizedBox(height: 6),
                  SummaryPrice(studio: s),
                  const SizedBox(height: 16),
                  SummaryActions(studio: s, onAdd: widget.onAdd, onSave: widget.onSave),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
