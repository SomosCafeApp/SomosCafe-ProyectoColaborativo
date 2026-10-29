import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/cup_snapshot.dart';
import '../../core/utils/art_saver.dart';
import '../../providers/drink_studio_provider.dart';
import 'cup_stage.dart';
import 'studio_colors.dart';
import 'studio_ui.dart';
import 'summary_actions.dart';
import 'summary_details.dart';

/// Pantalla de resultado: el latte terminado como protagonista (desde
/// arriba o de lado con su tapa), lo que lleva y las acciones. Es un
/// resultado ARTÍSTICO: no tiene precio ni carrito. Lo único que se
/// puede hacer con él es guardarlo como imagen en la galería.
class SummaryOverlay extends StatefulWidget {
  const SummaryOverlay({super.key});

  @override
  State<SummaryOverlay> createState() => _SummaryOverlayState();
}

class _SummaryOverlayState extends State<SummaryOverlay> {
  bool? _top;
  final GlobalKey _artKey = GlobalKey();

  Future<void> _saveArt() async {
    final message = await saveBoundaryToGallery(_artKey);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
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
    // Por defecto: desde arriba si hay arte o toppings que lucir.
    final top = _top ?? (s.latteArt.isNotEmpty || s.toppings.isNotEmpty || s.sweeteners.isNotEmpty);

    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
              child: Row(
                children: [
                  IconButton(tooltip: 'Volver a editar', onPressed: s.back, icon: Icon(Icons.arrow_back_rounded, color: StudioColors.text(dark))),
                  Expanded(child: Text('¡Tu latte está listo!', style: StudioUi.title(dark))),
                  const Icon(Icons.check_circle_rounded, color: StudioColors.primary),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(16, 4, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
                children: [
                  // ── Héroe: la bebida terminada ──
                  RepaintBoundary(
                    key: _artKey,
                    child: Container(
                    height: 330,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: dark ? const [Color(0xFF3A2C22), Color(0xFF2A2019)] : const [Color(0xFFFFF3E0), Color(0xFFF1DCC0)],
                      ),
                      boxShadow: [BoxShadow(color: StudioColors.primary.withValues(alpha: 0.18), blurRadius: 24, offset: const Offset(0, 10))],
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 12, 8, 36),
                            child: CupStage(snapshot: s.snapshot, view: top ? CupView.top : CupView.side, lidOn: !top, ambient: false),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 10,
                          child: Center(child: _ViewToggle(top: top, onChanged: (v) => setState(() => _top = v))),
                        ),
                      ],
                    ),
                  ),
                  ),
                  const SizedBox(height: 16),
                  Text(s.cupLabel, textAlign: TextAlign.center, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.4, color: StudioColors.text(dark))),
                  const SizedBox(height: 6),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: StudioColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                      child: const Text('Hecho en DrinkStudio', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: StudioColors.primary)),
                    ),
                  ),
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 16),
                  SummaryDetails(studio: s),
                ],
              ),
            ),
            // Acciones siempre a la vista.
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
              decoration: BoxDecoration(
                color: StudioColors.panel(dark),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 18, offset: const Offset(0, -4))],
              ),
              child: SummaryActions(studio: s, onSaveArt: _saveArt),
            ),
          ],
        ),
      ),
    );
  }
}

/// Interruptor "Desde arriba / De lado" flotando sobre la bebida.
class _ViewToggle extends StatelessWidget {
  const _ViewToggle({required this.top, required this.onChanged});
  final bool top;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    Widget item(String label, IconData icon, bool value) {
      final on = top == value;
      return GestureDetector(
        onTap: () => onChanged(value),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(gradient: on ? StudioColors.brand : null, borderRadius: BorderRadius.circular(30)),
          child: Row(
            children: [
              Icon(icon, size: 16, color: on ? Colors.white : StudioColors.primary),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: on ? Colors.white : StudioColors.text(dark))),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: StudioColors.panel(dark).withValues(alpha: 0.92), borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 8)]),
      child: Row(mainAxisSize: MainAxisSize.min, children: [item('Desde arriba', Icons.visibility_outlined, true), item('De lado', Icons.local_cafe_outlined, false)]),
    );
  }
}
