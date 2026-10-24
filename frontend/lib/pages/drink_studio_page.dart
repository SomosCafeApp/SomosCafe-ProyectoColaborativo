import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../animations/animations.dart';
import '../core/constants/app_colors.dart';
import '../models/drink_recipe.dart';
import '../models/drink_studio_stage.dart';
import '../models/product_model.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/drink_studio_provider.dart';
import '../providers/product_provider.dart';
import '../providers/recipes_provider.dart';
import '../widgets/common/styled_confirm_dialog.dart';
import '../widgets/drink_studio/last_recipe_banner.dart';
import '../widgets/drink_studio/studio_colors.dart';
import '../widgets/drink_studio/studio_dialogs.dart';
import '../widgets/drink_studio/studio_game_area.dart';
import '../widgets/drink_studio/studio_top_bar.dart';
import '../widgets/drink_studio/studio_tray.dart';
import '../widgets/drink_studio/summary_overlay.dart';

/// Estudio de bebidas: minijuego de preparación en UNA sola pantalla.
/// Es opcional (se abre desde la tarjeta o el detalle de una bebida) y
/// la compra convencional sigue intacta.
class DrinkStudioPage extends StatelessWidget {
  const DrinkStudioPage({super.key});

  /// Abre el estudio para [product]. Con [recipe] arranca con esa
  /// receta aplicada; si no, ofrece retomar la última del usuario.
  static Future<void> open(BuildContext context, Product product, {DrinkRecipe? recipe}) {
    return Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 420),
        reverseTransitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (ctx, _, _) => ChangeNotifierProvider(
          create: (c) {
            final studio = DrinkStudioProvider(product: product, catalog: c.read<ProductProvider>().products);
            final recipes = c.read<RecipesProvider>();
            studio.load().then((_) async {
              if (studio.status != StudioLoad.ready) return;
              if (recipe != null) {
                studio.applyRecipe(recipe);
              } else {
                studio.offerLastRecipe(await recipes.lastFor(product.id));
              }
            });
            return studio;
          },
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

  void _snack(BuildContext context, String text, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text), backgroundColor: error ? const Color(0xFFE53935) : AppColors.primary));
  }

  Future<void> _close(BuildContext context) async {
    final s = context.read<DrinkStudioProvider>();
    if (s.showSummary) {
      s.closeSummary();
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
      message: 'Perderás la bebida que estás preparando.',
      confirmLabel: 'Salir',
      cancelLabel: 'Seguir preparando',
    );
    if (leave && context.mounted) Navigator.of(context).pop();
  }

  Future<void> _finish(BuildContext context) async {
    final s = context.read<DrinkStudioProvider>();
    final pending = s.tabs.where((t) => !s.visited.contains(t)).toList();
    if (pending.isNotEmpty) {
      final go = await showStyledConfirmDialog(
        context,
        icon: Icons.local_cafe_rounded,
        title: '¿Terminar tu bebida?',
        message: 'Aún no has pasado por: ${pending.map((t) => t.label).join(', ')}. Puedes terminar así o seguir preparándola.',
        confirmLabel: 'Terminar',
        cancelLabel: 'Seguir preparando',
        destructive: false,
      );
      if (!go || !context.mounted) return;
    }
    s.openSummary();
  }

  Future<void> _save(BuildContext context) async {
    final recipes = context.read<RecipesProvider>();
    final s = context.read<DrinkStudioProvider>();
    if (!recipes.isLoggedIn) {
      _snack(context, 'Inicia sesión para guardar tus recetas');
      return;
    }
    final name = await showRecipeNameDialog(context);
    if (name == null || !context.mounted) return;
    final error = await s.saveRecipe(recipes, name: name);
    if (!context.mounted) return;
    _snack(context, error ?? 'Receta guardada en tu perfil', error: error != null);
  }

  Future<void> _add(BuildContext context) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (!context.read<AuthProvider>().isLoggedIn) {
      messenger.showSnackBar(const SnackBar(content: Text('Debes iniciar sesión para agregar productos al carrito')));
      return;
    }
    final s = context.read<DrinkStudioProvider>();
    final ok = await showStyledConfirmDialog(
      context,
      icon: Icons.shopping_bag_rounded,
      title: '¿Agregar al carrito?',
      message: 'Tu ${s.product.name} personalizada${s.pairings.isEmpty ? '' : ' y ${s.pairings.length} acompañamiento(s)'} quedará en tu carrito.',
      confirmLabel: 'Agregar',
      cancelLabel: 'Cancelar',
      destructive: false,
    );
    if (!ok || !context.mounted) return;

    final result = await s.addToCart(context.read<CartProvider>(), context.read<RecipesProvider>());
    if (result.error != null) {
      messenger.showSnackBar(SnackBar(content: Text(result.error!), backgroundColor: const Color(0xFFE53935)));
      if (!result.drinkAdded) return;
    } else {
      messenger.showSnackBar(SnackBar(content: Text('${s.product.name} personalizada añadida al carrito'), backgroundColor: AppColors.primary, duration: const Duration(seconds: 2)));
    }
    navigator.pop();
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
                        StudioTopBar(onClose: () => _close(context), onSave: () => _save(context)),
                        const LastRecipeBanner(),
                        const Expanded(child: StudioGameArea()),
                        SizedBox(height: (box.maxHeight * 0.46).clamp(280.0, 430.0), child: StudioTray(onFinish: () => _finish(context))),
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
                        ? SummaryOverlay(key: const ValueKey('summary'), onAdd: () => _add(context), onSave: () => _save(context))
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
            Text('No pudimos abrir el estudio', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: StudioColors.text(dark))),
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
