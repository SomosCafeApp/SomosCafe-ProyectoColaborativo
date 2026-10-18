import 'package:flutter/material.dart';

import '../../common/styled_confirm_dialog.dart';

/// Resultado del diálogo de eliminación.
enum DeleteProductChoice { cancel, hide, delete }

/// Pregunta antes de borrar un producto y explica la diferencia con
/// ocultarlo del menú. Devuelve lo que eligió el admin.
Future<DeleteProductChoice> askDeleteProduct(BuildContext context, String productName) {
  return showStyledChoiceDialog<DeleteProductChoice>(
    context,
    icon: Icons.delete_outline_rounded,
    title: 'Eliminar producto',
    message: '"$productName" se borrará definitivamente de la base de datos y se quitará de '
        'los carritos, favoritos, reseñas y promociones.\n\n'
        'Los pedidos ya realizados se conservan con su propia copia del producto.\n\n'
        'Si solo quieres que deje de aparecer en el menú, ocúltalo en lugar de eliminarlo.',
    cancelValue: DeleteProductChoice.cancel,
    choices: const [
      StyledDialogChoice(value: DeleteProductChoice.hide, label: 'Solo ocultar'),
      StyledDialogChoice(
        value: DeleteProductChoice.delete,
        label: 'Eliminar',
        destructive: true,
      ),
    ],
  );
}
