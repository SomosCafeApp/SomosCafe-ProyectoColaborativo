import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../animations/animations.dart';
import '../models/drink_studio_stage.dart';
import '../providers/auth_provider.dart';
import '../providers/drink_studio_provider.dart';
import '../widgets/common/styled_confirm_dialog.dart';
import '../widgets/drink_studio/studio_colors.dart';
import '../widgets/drink_studio/studio_game_area.dart';
import '../widgets/drink_studio/studio_top_bar.dart';
import '../widgets/drink_studio/studio_tray.dart';

/// DrinkStudio: preparar un latte a tu manera, en UNA sola pantalla, y
/// comprarlo. El vaso es el mismo escenario durante todo el recorrido
/// (solo cambia la cámara); al final «Comprar latte» agrega la bebida al
/// carrito real, validada y cotizada por el servidor.
class DrinkStudioPage extends StatefulWidget {
  const DrinkStudioPage({super.key});

  /// Abre DrinkStudio (el minijuego del latte).
  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 420),
        reverseTransitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (ctx, _, _) => ChangeNotifierProvider(
          create: (ctx) =>
              DrinkStudioProvider.latte(token: ctx.read<AuthProvider>().token)
                ..load(),
          child: const DrinkStudioPage(),
        ),
        transitionsBuilder: (ctx, anim, _, child) {
          final curved = CurvedAnimation(
            parent: anim,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0, 0.06),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  State<DrinkStudioPage> createState() => _DrinkStudioPageState();
}

class _DrinkStudioPageState extends State<DrinkStudioPage> {
  bool _draftChecked = false;

  /// Si quedó una bebida a medias, se ofrece retomarla (nunca se aplica
  /// sola: el usuario decide).
  Future<void> _offerDraft(DrinkStudioProvider s) async {
    if (_draftChecked) return;
    _draftChecked = true;
    final draft = await s.pendingDraft();
    if (draft == null || !mounted) return;
    final resume = await showStyledConfirmDialog(
      context,
      icon: Icons.local_cafe_rounded,
      title: 'Tienes un latte a medias',
      message: '¿Quieres retomarlo donde lo dejaste?',
      confirmLabel: 'Retomar',
      cancelLabel: 'Empezar de nuevo',
      destructive: false,
    );
    if (!mounted) return;
    if (resume) {
      s.resumeDraft(draft);
    } else {
      s.discardDraft();
    }
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
      message:
          'Tu latte se guarda en este dispositivo para que puedas retomarlo.',
      confirmLabel: 'Salir',
      cancelLabel: 'Seguir preparando',
    );
    if (leave && context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<DrinkStudioProvider>();
    if (s.status == StudioLoad.ready) _offerDraft(s);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close(context);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        resizeToAvoidBottomInset: false,
        body: switch (s.status) {
          StudioLoad.loading => const SafeArea(
            child: Center(child: CoffeeCupLoader(size: 64)),
          ),
          StudioLoad.error => SafeArea(
            child: _ErrorView(
              message: s.error ?? 'Error',
              onRetry: s.load,
              onClose: () => Navigator.of(context).pop(),
            ),
          ),
          StudioLoad.ready => SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, box) {
                // La bandeja crece en la presentación final; el vaso de
                // arriba es el MISMO escenario (no se recrea).
                final f = switch (s.step) {
                  StudioStep.result => 0.56,
                  StudioStep.toppings || StudioStep.art => 0.46,
                  _ => 0.42,
                };
                return Column(
                  children: [
                    StudioTopBar(onClose: () => _close(context)),
                    const Expanded(child: StudioGameArea()),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 420),
                      curve: Curves.easeInOutCubic,
                      height: (box.maxHeight * f).clamp(
                        270.0,
                        s.showSummary ? 520.0 : 430.0,
                      ),
                      child: const StudioTray(),
                    ),
                  ],
                );
              },
            ),
          ),
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
    required this.onClose,
  });
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
            const Icon(
              Icons.coffee_maker_outlined,
              size: 56,
              color: StudioColors.primary,
            ),
            const SizedBox(height: 14),
            Text(
              'No pudimos abrir DrinkStudio',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: StudioColors.text(dark),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: StudioColors.muted(dark)),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: StudioColors.primary,
              ),
              child: const Text('Reintentar'),
            ),
            TextButton(onPressed: onClose, child: const Text('Volver')),
          ],
        ),
      ),
    );
  }
}
