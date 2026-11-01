import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/art_saver.dart';
import '../../models/drink_studio_stage.dart';
import '../../pages/cart_page.dart';
import '../../pages/login_page.dart';
import '../../providers/cart_provider.dart';
import '../../providers/drink_studio_provider.dart';
import '../../providers/recipes_provider.dart';
import '../common/styled_confirm_dialog.dart';
import 'studio_colors.dart';

/// Acciones de la presentación final: personalizar de nuevo, guardar la
/// imagen y «Comprar latte». Comprar agrega la bebida al carrito REAL
/// (tras validarla el servidor) y lleva al flujo normal de compra:
/// entrega, dirección, método de pago y confirmación. No simula pagos.
class SummaryActions extends StatelessWidget {
  const SummaryActions({super.key, required this.studio});
  final DrinkStudioProvider studio;

  /// Elegir qué parte de la bebida volver a personalizar.
  Future<void> _edit(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(padding: EdgeInsets.only(bottom: 8), child: Text('¿Qué quieres cambiar?', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16))),
            for (final step in studio.steps.where((x) => x != StudioStep.result))
              ListTile(
                leading: Icon(step.icon, color: StudioColors.primary),
                title: Text(step.label),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(sheet);
                  studio.clearPurchaseStatus();
                  studio.goToStep(step);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(BuildContext context) async {
    final message = await saveBoundaryToGallery(studio.artKey);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _reset(BuildContext context) async {
    final ok = await showStyledConfirmDialog(
      context,
      icon: Icons.refresh_rounded,
      title: '¿Empezar de nuevo?',
      message: 'Se borrará todo lo que preparaste hasta ahora.',
      confirmLabel: 'Reiniciar',
      cancelLabel: 'Cancelar',
      destructive: true,
    );
    if (ok) studio.restart();
  }

  Future<void> _buy(BuildContext context) async {
    final cart = context.read<CartProvider>();
    final recipes = context.read<RecipesProvider>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final custom = studio.customization;
    final level = studio.milkLevel;
    final productId = studio.product.id;

    final ok = await studio.buy(cart);
    if (!context.mounted) return;

    if (ok) {
      // Queda como bebida reciente para volver a pedirla.
      recipes.recordRecent(productId, custom, level);
      final goCart = await showModalBottomSheet<bool>(
        context: context,
        showDragHandle: true,
        builder: (sheet) => _AddedSheet(studio: studio),
      );
      studio.clearPurchaseStatus();
      if (goCart == true) {
        navigator.push(MaterialPageRoute<void>(builder: (_) => const CartPage(showBack: true)));
      }
      return;
    }

    final message = studio.purchaseMessage ?? 'No pudimos agregar tu latte.';
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 5),
          action: studio.purchaseNeedsLogin
              ? SnackBarAction(
                  label: 'Iniciar sesión',
                  textColor: Colors.white,
                  onPressed: () => navigator.push(MaterialPageRoute<void>(builder: (_) => const LoginPage())),
                )
              : null,
        ),
      );
    studio.clearPurchaseStatus();
  }

  @override
  Widget build(BuildContext context) {
    final busy = studio.buying;
    final minor = TextButton.styleFrom(foregroundColor: StudioColors.primary, visualDensity: VisualDensity.compact, textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13));
    final total = studio.hasRealProduct ? ' · ${_money(studio.drinkTotal)}' : '';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Semantics(
              button: true,
              label: 'Personalizar de nuevo',
              child: OutlinedButton(
                onPressed: busy ? null : () => _edit(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: StudioColors.primary,
                  side: const BorderSide(color: StudioColors.primary, width: 1.6),
                  minimumSize: const Size(54, 54),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Icon(Icons.tune_rounded),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: studio.canBuy ? StudioColors.brand : null,
                  color: studio.canBuy ? null : StudioColors.latte.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: studio.canBuy ? [BoxShadow(color: StudioColors.primary.withValues(alpha: 0.35), blurRadius: 14, offset: const Offset(0, 6))] : const [],
                ),
                child: FilledButton.icon(
                  // Mientras valida, el botón queda bloqueado: no hay doble envío.
                  onPressed: studio.hasRealProduct && !busy ? () => _buy(context) : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    disabledBackgroundColor: Colors.transparent,
                    disabledForegroundColor: Colors.white70,
                    shadowColor: Colors.transparent,
                    minimumSize: const Size(0, 54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  icon: busy
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.shopping_bag_rounded),
                  label: Text(busy ? 'Validando…' : 'Comprar latte$total', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(onPressed: busy ? null : () => _save(context), icon: const Icon(Icons.download_rounded, size: 17), label: const Text('Guardar imagen'), style: minor),
            TextButton.icon(onPressed: busy ? null : () => _reset(context), icon: const Icon(Icons.refresh_rounded, size: 17), label: const Text('Jugar de nuevo'), style: minor),
          ],
        ),
      ],
    );
  }

  static String _money(double v) {
    final n = v.round().toString();
    final b = StringBuffer();
    for (var i = 0; i < n.length; i++) {
      if (i > 0 && (n.length - i) % 3 == 0) b.write('.');
      b.write(n[i]);
    }
    return '\$$b';
  }
}

/// Confirmación discreta al agregar la bebida: ir al carrito (flujo
/// normal de compra) o seguir en DrinkStudio con la bebida intacta.
class _AddedSheet extends StatelessWidget {
  const _AddedSheet({required this.studio});
  final DrinkStudioProvider studio;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.4, end: 1),
              duration: const Duration(milliseconds: 420),
              curve: Curves.easeOutBack,
              builder: (_, v, child) => Transform.scale(scale: v, child: child),
              child: Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 38),
              ),
            ),
            const SizedBox(height: 14),
            Text('¡Tu latte está en el carrito!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: StudioColors.text(dark))),
            const SizedBox(height: 4),
            Text('${studio.quantity} × ${studio.cupLabel} · ${SummaryActions._money(studio.drinkTotal)}', style: TextStyle(color: StudioColors.muted(dark))),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size(0, 52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                child: const Text('Ir al carrito y pagar', style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Seguir en DrinkStudio')),
          ],
        ),
      ),
    );
  }
}
