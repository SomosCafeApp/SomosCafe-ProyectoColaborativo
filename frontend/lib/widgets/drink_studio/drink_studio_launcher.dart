import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../animations/animations.dart';
import '../../core/constants/app_colors.dart';
import '../../models/product_model.dart';
import '../../pages/drink_studio_page.dart';
import '../../providers/product_provider.dart';
import 'drink_studio_entry.dart';
import 'studio_colors.dart';

/// Abre el Estudio de bebidas desde cualquier lugar de la app.
///
/// El acceso NO depende de una bebida concreta: si se indica [preselect]
/// y es compatible, abre el estudio directo con ella; si no, ofrece una
/// lista para elegir la bebida a personalizar. Si todavía no hay bebidas
/// disponibles, avisa en vez de quedarse mudo.
Future<void> openDrinkStudio(BuildContext context, {Product? preselect}) async {
  if (preselect != null && DrinkStudioFab.supports(preselect)) {
    await DrinkStudioPage.open(context, preselect);
    return;
  }

  final provider = context.read<ProductProvider>();
  final drinks = provider.products.where(DrinkStudioFab.supports).toList();
  final messenger = ScaffoldMessenger.of(context);

  if (drinks.isEmpty) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(provider.isLoading
            ? 'Estamos cargando el menú. Inténtalo en un momento.'
            : 'Por ahora no hay bebidas disponibles para personalizar.'),
      ));
    return;
  }

  final chosen = await showModalBottomSheet<Product>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) => _DrinkPickerSheet(drinks: drinks),
  );

  if (chosen != null && context.mounted) {
    await DrinkStudioPage.open(context, chosen);
  }
}

class _DrinkPickerSheet extends StatelessWidget {
  const _DrinkPickerSheet({required this.drinks});
  final List<Product> drinks;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: height * 0.7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 4),
              child: Text('Estudio de bebidas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text('Elige la bebida que quieres preparar y personalizar.', style: TextStyle(fontSize: 13)),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: drinks.length,
                itemBuilder: (ctx, i) {
                  final p = drinks[i];
                  final hasImage = p.imageUrl.startsWith('http');
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: hasImage
                            ? Image.network(
                                p.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => const Icon(Icons.local_cafe_rounded),
                              )
                            : const Icon(Icons.local_cafe_rounded),
                      ),
                    ),
                    title: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.pop(ctx, p),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Botón flotante pequeño y único para abrir el Estudio de bebidas. Vive
/// en la pantalla (no en las tarjetas de bebidas), así que siempre está
/// disponible aunque cambie el menú.
class DrinkStudioLauncher extends StatelessWidget {
  const DrinkStudioLauncher({super.key});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Estudio de bebidas',
      child: Semantics(
        button: true,
        label: 'Abrir el estudio de bebidas',
        child: Breathing(
          scale: 1.06,
          child: PressScale(
            onTap: () => openDrinkStudio(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: StudioColors.brand,
                boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: const Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Icon(Icons.local_cafe_rounded, size: 22, color: Colors.white),
                  Positioned(top: 8, right: 8, child: Icon(Icons.auto_awesome_rounded, size: 11, color: AppColors.accentYellow)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
