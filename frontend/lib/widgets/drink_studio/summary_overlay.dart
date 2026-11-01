import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/drink_studio_provider.dart';
import 'studio_colors.dart';
import 'studio_ui.dart';
import 'summary_details.dart';

/// Presentación final de la bebida (panel de la bandeja). El vaso NO se
/// vuelve a dibujar aquí: sigue siendo el mismo escenario de arriba, que
/// solo cambia de ángulo, así no hay saltos ni se reinician animaciones.
/// Muestra el nombre del vaso, lo que lleva, el precio verificable por
/// el servidor y la cantidad.
class SummaryOverlay extends StatefulWidget {
  const SummaryOverlay({super.key});

  @override
  State<SummaryOverlay> createState() => _SummaryOverlayState();
}

class _SummaryOverlayState extends State<SummaryOverlay> {
  late final TextEditingController _name = TextEditingController(text: context.read<DrinkStudioProvider>().cupName);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<DrinkStudioProvider>();
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(s.cupLabel, maxLines: 1, overflow: TextOverflow.ellipsis, style: StudioUi.title(dark))),
              const Icon(Icons.check_circle_rounded, color: StudioColors.primary),
            ],
          ),
          const SizedBox(height: 2),
          Text('¡Tu latte está listo!', style: TextStyle(fontSize: 13, color: StudioColors.muted(dark))),
          const SizedBox(height: 12),
          TextField(
            controller: _name,
            maxLength: 18,
            textCapitalization: TextCapitalization.words,
            onChanged: s.setCupName,
            decoration: InputDecoration(
              labelText: 'Nombre en tu vaso',
              hintText: s.product.name,
              counterText: '',
              prefixIcon: const Icon(Icons.edit_rounded, color: StudioColors.primary),
              filled: true,
              fillColor: StudioColors.soft(dark),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 14),
          SummaryDetails(studio: s),
          const SizedBox(height: 14),
          if (s.hasRealProduct)
            SummaryPrice(studio: s)
          else
            _Unavailable(dark: dark),
          if (s.priceNotice != null) ...[
            const SizedBox(height: 8),
            Text(s.priceNotice!, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: StudioColors.primary)),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _Unavailable extends StatelessWidget {
  const _Unavailable({required this.dark});
  final bool dark;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: StudioColors.soft(dark), borderRadius: BorderRadius.circular(18)),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: StudioColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'El latte no está disponible para pedir en este momento. Puedes guardar tu bebida como imagen.',
                style: TextStyle(fontSize: 13, color: StudioColors.text(dark)),
              ),
            ),
          ],
        ),
      );
}
