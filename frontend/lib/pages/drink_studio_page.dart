import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../animations/animations.dart';
import '../models/drink_studio_stage.dart';
import '../providers/drink_studio_provider.dart';
import '../widgets/common/styled_confirm_dialog.dart';
import '../widgets/drink_studio/studio_colors.dart';
import '../widgets/drink_studio/studio_game_area.dart';
import '../widgets/drink_studio/studio_top_bar.dart';
import '../widgets/drink_studio/studio_tray.dart';
import '../widgets/drink_studio/summary_overlay.dart';

/// DrinkStudio: minijuego independiente para preparar un latte, en UNA
/// sola pantalla. Se abre directo desde su ícono y no tiene relación con
/// el catálogo: no usa productos, no tiene precios y no toca el carrito.
class DrinkStudioPage extends StatelessWidget {
  const DrinkStudioPage({super.key});

  /// Abre DrinkStudio (el minijuego del latte).
  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 420),
        reverseTransitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (ctx, _, _) => ChangeNotifierProvider(
          create: (_) => DrinkStudioProvider.latte()..load(),
          child: const DrinkStudioPage(),
        ),
        transitionsBuilder: (ctx, anim, _, child) {
          final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(position: Tween(begin: const Offset(0, 0.06), end: Offset.zero).animate(curved), child: child),
          );
        },
      ),
    );
  }

  Future<void> _close(BuildContext context) async {
    final s = context.read<DrinkStudioProvider>();
    if (s.showSummary) {
      s.back();
      return;
    }
    if (!s.hasProgress) {
      Navigator.of(context).pop();
      return;
    }
    final leave = await showStyledConfirmDialog(
      context,
      icon: Icons.exit_to_app_rounded,
      title: '¿Salir sin terminar?',
      message: 'Perderás el latte que estás preparando.',
      confirmLabel: 'Salir',
      cancelLabel: 'Seguir preparando',
    );
    if (leave && context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<DrinkStudioProvider>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close(context);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        resizeToAvoidBottomInset: false,
        body: switch (s.status) {
          StudioLoad.loading => const SafeArea(child: Center(child: CoffeeCupLoader(size: 64))),
          StudioLoad.error => SafeArea(child: _ErrorView(message: s.error ?? 'Error', onRetry: s.load, onClose: () => Navigator.of(context).pop())),
          StudioLoad.ready => Stack(
              children: [
                SafeArea(
                  bottom: false,
                  child: LayoutBuilder(
                    builder: (context, box) => Column(
                      children: [
                        StudioTopBar(onClose: () => _close(context)),
                        const Expanded(child: StudioGameArea()),
                        SizedBox(height: (box.maxHeight * (s.step == StudioStep.toppings || s.step == StudioStep.art ? 0.46 : 0.42)).clamp(270.0, 430.0), child: const StudioTray()),
                      ],
                    ),
                  ),
                ),
                Positioned.fill(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 380),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(position: Tween(begin: const Offset(0, 0.05), end: Offset.zero).animate(anim), child: child),
                    ),
                    child: s.showSummary
                        ? const SummaryOverlay(key: ValueKey('summary'))
                        : const SizedBox.shrink(key: ValueKey('none')),
                  ),
                ),
              ],
            ),
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry, required this.onClose});
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.coffee_maker_outlined, size: 56, color: StudioColors.primary),
            const SizedBox(height: 14),
            Text('No pudimos abrir DrinkStudio', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: StudioColors.text(dark))),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center, style: TextStyle(color: StudioColors.muted(dark))),
            const SizedBox(height: 20),
            FilledButton(onPressed: onRetry, style: FilledButton.styleFrom(backgroundColor: StudioColors.primary), child: const Text('Reintentar')),
            TextButton(onPressed: onClose, child: const Text('Volver')),
          ],
        ),
      ),
    );
  }
}
