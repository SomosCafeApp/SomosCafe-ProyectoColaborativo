import 'package:flutter/material.dart';

/// Resultado del diálogo de eliminación.
enum DeleteProductChoice { cancel, hide, delete }

/// Pregunta antes de borrar un producto y explica la diferencia con
/// ocultarlo del menú. Devuelve lo que eligió el admin.
Future<DeleteProductChoice> askDeleteProduct(BuildContext context, String productName) async {
  final result = await showDialog<DeleteProductChoice>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Eliminar producto'),
      content: Text(
        '"$productName" se borrará definitivamente de la base de datos y se quitará de '
        'los carritos, favoritos, reseñas y promociones.\n\n'
        'Los pedidos ya realizados se conservan con su propia copia del producto.\n\n'
        'Si solo quieres que deje de aparecer en el menú, ocúltalo en lugar de eliminarlo.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, DeleteProductChoice.cancel),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, DeleteProductChoice.hide),
          child: const Text('Solo ocultar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, DeleteProductChoice.delete),
          child: const Text('Eliminar', style: TextStyle(color: Color(0xFFE53935))),
        ),
      ],
    ),
  );
  return result ?? DeleteProductChoice.cancel;
}
