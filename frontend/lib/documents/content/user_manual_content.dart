// GENERADO a partir del contenido oficial del documento. Para cambiar el
// texto edita este archivo directamente (y actualiza la fecha/versión).
import 'package:flutter/material.dart';

import '../app_document.dart';

const AppDocument userManualDocument = AppDocument(
  id: 'user_manual',
  title: 'Manual de Usuario',
  subtitle: 'Cómo usar la app paso a paso',
  icon: Icons.menu_book_rounded,
  accent: Color(0xFFB7791F),
  intro: 'Guía rápida para sacarle el máximo provecho a SomosCafe App. La barra inferior tiene cinco pestañas: Inicio, Menú, Buscar, Carrito y Perfil.',
  meta: 'Versión de la app 1.0.0 · Actualizado: 13 de noviembre de 2026',
  numbered: false,
  sections: [
    DocSection(
      icon: Icons.login_rounded,
      accent: Color(0xFFB7791F),
      title: '1. Crear tu cuenta e iniciar sesión',
      blocks: [
        DocBlock.ul([
          'Toca Regístrate aquí, completa nombre, apellido, correo y una contraseña (mínimo 6 caracteres con mayúscula, minúscula, número y carácter especial).',
          'Si quieres, elige tu avatar: uno de los cinco predefinidos o una foto de tu galería.',
          'Marca la casilla para aceptar los Términos y la Política de Privacidad y toca Crear cuenta.',
          'Te enviaremos un código a tu correo: escríbelo para verificar tu cuenta y luego inicia sesión.',
          'También puedes entrar con Google con un solo toque.',
        ]),
      ],
    ),
    DocSection(
      icon: Icons.key_rounded,
      accent: Color(0xFFF2A81D),
      title: '2. ¿Olvidaste tu contraseña?',
      blocks: [
        DocBlock.p('En la pantalla de inicio de sesión toca ¿Olvidaste tu contraseña?, escribe tu correo, ingresa el código que te llega y crea una contraseña nueva. Más adelante la puedes cambiar en Perfil > Configuración > Seguridad.'),
      ],
    ),
    DocSection(
      icon: Icons.home_outlined,
      accent: Color(0xFF2FA36B),
      title: '3. Inicio',
      blocks: [
        DocBlock.p('Aquí ves ofertas y promociones, categorías, los productos más populares y avisos de eventos. Toca cualquier producto o promoción para ver el detalle.'),
      ],
    ),
    DocSection(
      icon: Icons.restaurant_menu_rounded,
      accent: Color(0xFFE07B39),
      title: '4. Menú y búsqueda',
      blocks: [
        DocBlock.ul([
          'En Menú navega por categorías con los chips de arriba.',
          'En Buscar escribe el nombre de un producto para encontrarlo rápido.',
          'Toca el corazón de un producto para guardarlo en Favoritos (Perfil > Favoritos).',
        ]),
      ],
    ),
    DocSection(
      icon: Icons.tune_rounded,
      accent: Color(0xFF4A90C2),
      title: '5. Personalizar un producto',
      blocks: [
        DocBlock.p('En el detalle del producto elige tamaño, tipo, leche y extras. El precio se actualiza al instante. Revisa el resumen, elige la cantidad y toca Agregar al carrito. También puedes leer y dejar reseñas de los productos.'),
      ],
    ),
    DocSection(
      icon: Icons.shopping_cart_outlined,
      accent: Color(0xFF2FA36B),
      title: '6. Carrito y confirmación del pedido',
      blocks: [
        DocBlock.ul([
          'En Carrito cambia cantidades o elimina productos.',
          'Toca continuar para confirmar: elige A domicilio o En local.',
          'Si es a domicilio, selecciona o agrega una dirección en Garzón y los datos de quien recibe. El domicilio cuesta \$5.000.',
          'Elige el método de pago (efectivo o transferencia) y, si tienes, aplica un cupón.',
          'Revisa el resumen y confirma.',
        ]),
      ],
    ),
    DocSection(
      icon: Icons.payments_outlined,
      accent: Color(0xFF2A9D8F),
      title: '7. Pagar por transferencia',
      blocks: [
        DocBlock.p('Si eliges transferencia verás el código QR de la cafetería (puedes guardarlo en tu galería). Haz el pago desde tu app bancaria y sube la captura del comprobante. Nuestro equipo lo valida; si todo está bien tu pedido avanza, y si no, te avisamos por notificación.'),
      ],
    ),
    DocSection(
      icon: Icons.receipt_long_rounded,
      accent: Color(0xFF4A90C2),
      title: '8. Seguir o cancelar un pedido',
      blocks: [
        DocBlock.p('En Perfil > Historial de Pedidos ves el estado de cada pedido: Pendiente, Confirmado, En preparación, Listo, En camino, Entregado o Cancelado. Puedes tocar Cancelar mientras esté Pendiente o Confirmado y dentro de los 10 minutos que muestra el contador.'),
      ],
    ),
    DocSection(
      icon: Icons.card_giftcard_rounded,
      accent: Color(0xFFE07B39),
      title: '9. Puntos y cupones',
      blocks: [
        DocBlock.p('Ganas 1 punto por cada \$1.000 en productos de un pedido entregado (mínimo 1 por pedido). En Perfil > Recompensas puedes ver tu saldo, tu historial de puntos, canjear cupones del catálogo y consultar Mis cupones. Aplica el cupón al confirmar tu pedido.'),
      ],
    ),
    DocSection(
      icon: Icons.chat_bubble_outline_rounded,
      accent: Color(0xFF8B6CD9),
      title: '10. ChatBot',
      blocks: [
        DocBlock.ul([
          'Toca el botón flotante del chat para pedir ayuda, recibir recomendaciones o armar un pedido conversando.',
          'Puedes dictar con el micrófono y activar la lectura de las respuestas en voz alta.',
          'El ChatBot puede agregar productos a tu carrito; siempre revisa el carrito y confirma tú el pedido.',
        ]),
      ],
    ),
    DocSection(
      icon: Icons.sports_esports_outlined,
      accent: Color(0xFFE5558A),
      title: '11. DrinkStudio',
      blocks: [
        DocBlock.p('Es un minijuego para preparar tu bebida y crear arte latte. Se abre desde su ícono flotante o desde Configuración > DrinkStudio, donde también puedes ajustar vibración, efectos y animaciones. Es solo diversión: no genera un pedido.'),
      ],
    ),
    DocSection(
      icon: Icons.notifications_none_rounded,
      accent: Color(0xFFF2A81D),
      title: '12. Notificaciones',
      blocks: [
        DocBlock.p('En Perfil > Notificaciones ves lo que has recibido y eliges si quieres avisos de promociones y de novedades. Los avisos de tus pedidos siempre llegan. Si no te llegan, revisa que las notificaciones de la app estén permitidas en los ajustes del teléfono.'),
      ],
    ),
    DocSection(
      icon: Icons.settings_rounded,
      accent: Color(0xFFB7791F),
      title: '13. Perfil y configuración',
      blocks: [
        DocBlock.ul([
          'Direcciones: guarda tus lugares de entrega.',
          'Configuración > Apariencia: modo oscuro y tamaño del texto (Pequeño, Mediano o Grande).',
          'Configuración > Cuenta: edita nombre, teléfono y cumpleaños.',
          'Configuración > Seguridad: cambia tu contraseña.',
          'Configuración > Soporte: Centro de Ayuda (ChatBot) y WhatsApp.',
          'Configuración > Documentos: manuales, términos y política de privacidad.',
        ]),
      ],
    ),
    DocSection(
      icon: Icons.support_agent_rounded,
      accent: Color(0xFF2FA36B),
      title: '14. Ayuda',
      blocks: [
        DocBlock.p('Si algo no sale como esperabas, revisa las Preguntas frecuentes, escribe al Centro de Ayuda o contáctanos por WhatsApp desde Configuración > Soporte.'),
      ],
    ),
  ],
);
