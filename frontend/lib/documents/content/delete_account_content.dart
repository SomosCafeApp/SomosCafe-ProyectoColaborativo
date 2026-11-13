// GENERADO a partir del contenido oficial del documento. Para cambiar el
// texto edita este archivo directamente (y actualiza la fecha/versión).
import 'package:flutter/material.dart';

import '../app_document.dart';

const AppDocument deleteAccountDocument = AppDocument(
  id: 'delete_account',
  title: 'Eliminar mi cuenta y mis datos',
  subtitle: 'Cómo borrar tu cuenta',
  icon: Icons.delete_outline_rounded,
  accent: Color(0xFFE53935),
  intro: 'Puedes eliminar tu cuenta de SomosCafe App y los datos asociados cuando quieras.',
  meta: 'Versión de la app 1.0.0 · Actualizado: 13 de noviembre de 2026',
  numbered: false,
  sections: [
    DocSection(
      icon: Icons.phone_android_rounded,
      accent: Color(0xFFE53935),
      title: 'Desde la app',
      blocks: [
        DocBlock.ul([
          'Inicia sesión y ve a Perfil > Configuración > Datos personales.',
          'Desplázate hasta el final y toca Eliminar cuenta.',
          'Escribe la palabra ELIMINAR para confirmar y, si tu cuenta tiene contraseña, escríbela también.',
          'Toca confirmar. Tu sesión se cerrará y la cuenta quedará eliminada.',
        ]),
        DocBlock.note('No puedes eliminar la cuenta si tienes pedidos en curso: espera a que se entreguen o cancélalos primero. Las cuentas de administrador no se eliminan desde la app.'),
      ],
    ),
    DocSection(
      icon: Icons.mail_outline_rounded,
      accent: Color(0xFF4A90C2),
      title: 'Si no puedes entrar a la app',
      blocks: [
        DocBlock.p('Escribe a legal@coffeeapp.co desde el correo con el que te registraste, con el asunto "Eliminar mi cuenta" e indica tu nombre. Atenderemos tu solicitud dentro de los plazos de la Ley 1581 de 2012.'),
      ],
    ),
    DocSection(
      icon: Icons.storage_rounded,
      accent: Color(0xFF8B6CD9),
      title: 'Qué se elimina',
      blocks: [
        DocBlock.ul([
          'Tu nombre, apellido, correo, teléfono, fecha de cumpleaños y el vínculo con Google.',
          'Tu foto de perfil o avatar.',
          'Tus direcciones, carrito, favoritos, notificaciones y chats del ChatBot.',
          'Tus puntos, cupones y métodos de pago guardados.',
          'Los tokens de notificaciones de tus dispositivos.',
          'El nombre, teléfono y dirección de entrega de tus pedidos anteriores y tus comprobantes de pago.',
        ]),
      ],
    ),
    DocSection(
      icon: Icons.inventory_2_outlined,
      accent: Color(0xFFF2A81D),
      title: 'Qué se conserva',
      blocks: [
        DocBlock.p('Los registros de ventas (productos y montos), sin ningún dato que te identifique, pueden conservarse para cumplir obligaciones contables y tributarias. La eliminación es definitiva y no se puede deshacer; si quieres volver, tendrás que crear una cuenta nueva.'),
      ],
    ),
  ],
);
