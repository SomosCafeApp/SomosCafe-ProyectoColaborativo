import 'package:flutter/material.dart';

/// Una sección de los Términos y Condiciones.
class TermsSection {
  final IconData icon;
  final Color accent;
  final String title;
  final String body;

  const TermsSection({
    required this.icon,
    required this.accent,
    required this.title,
    required this.body,
  });
}

/// Datos que se muestran al pie y bajo el título de la página.
/// Cámbialos aquí cuando actualices los términos.
const String termsLastUpdate = '1 de septiembre de 2026';
const String termsContactEmail = 'legal@coffeeapp.co';
const String termsFooterLine = '© 2026 SOMOS CafeApp · Garzón, Huila';

/// Contenido de los términos, adaptado al funcionamiento actual de la app.
const List<TermsSection> termsSections = [
  TermsSection(
    icon: Icons.people_outline_rounded,
    accent: Color(0xFFB7791F),
    title: 'Aceptación de los Términos',
    body: 'Al crear una cuenta o usar esta aplicación aceptas estar vinculado '
        'por estos Términos y Condiciones. Si no estás de acuerdo con alguna '
        'de las condiciones aquí establecidas, no debes utilizar la '
        'aplicación. Nos reservamos el derecho de actualizar estos términos '
        'en cualquier momento; la fecha de la última actualización aparece '
        'al inicio de esta página.',
  ),
  TermsSection(
    icon: Icons.inventory_2_outlined,
    accent: Color(0xFF4A90C2),
    title: 'Uso del Servicio',
    body: 'Esta aplicación está destinada a facilitar la compra de productos '
        'en nuestra cafetería, ya sea para recoger en el local o para '
        'recibirlos en tu dirección. Te comprometes a dar datos verdaderos, '
        'a mantener tu cuenta y contraseña en reserva y a usar el servicio '
        'solo para fines legales. Queda prohibido el uso fraudulento de la '
        'aplicación, de los cupones o de los comprobantes de pago, así como '
        'publicar reseñas ofensivas o que infrinjan derechos de terceros.',
  ),
  TermsSection(
    icon: Icons.credit_card_outlined,
    accent: Color(0xFF2FA36B),
    title: 'Pagos y Precios',
    body: 'Los precios están expresados en Pesos Colombianos (COP) e incluyen '
        'impuestos aplicables. Los pedidos con envío tienen un costo de '
        'domicilio de \$5.000; recoger en el local no tiene costo adicional. '
        'Puedes pagar en efectivo (al domiciliario o en la cafetería, según '
        'el tipo de entrega) o por transferencia: al continuar verás un '
        'código QR, y luego debes subir la captura de tu pago. Nuestro '
        'equipo revisará el comprobante y lo validará o lo invalidará; si se '
        'invalida, el pedido se cancela y recibirás una notificación. '
        'Podemos modificar los precios sin previo aviso, sin afectar los '
        'pedidos ya realizados.',
  ),
  TermsSection(
    icon: Icons.shield_outlined,
    accent: Color(0xFF8B6CD9),
    title: 'Privacidad y Datos',
    body: 'Recopilamos y procesamos tus datos personales (como nombre, '
        'correo, teléfono, direcciones y comprobantes de pago) únicamente '
        'para gestionar tus pedidos, mejorar el servicio y enviarte '
        'notificaciones, que puedes configurar desde la app. Nunca vendemos '
        'tu información a terceros. Puedes editar tus datos en cualquier '
        'momento y eliminar tu cuenta desde Configuración > Datos '
        'personales; tus pedidos anteriores se conservan sin tus datos '
        'personales.',
  ),
  TermsSection(
    icon: Icons.error_outline_rounded,
    accent: Color(0xFFF2A81D),
    title: 'Pedidos y Cancelaciones',
    body: 'Un pedido solo puede cancelarse desde la sección Pedidos mientras '
        'esté pendiente o confirmado y dentro del tiempo que indica el '
        'contador de cancelación; una vez que se empieza a preparar, no '
        'garantizamos su cancelación. Si necesitas ayuda, comunícate de '
        'inmediato con nuestro servicio de atención. Si pagaste por '
        'transferencia y el pedido se cancela, te indicaremos cómo gestionar '
        'la devolución. Los tiempos de preparación y entrega son estimados '
        'y pueden variar.',
  ),
  TermsSection(
    icon: Icons.stars_outlined,
    accent: Color(0xFFE07B39),
    title: 'Puntos y Cupones',
    body: 'Ganas 1 punto por cada \$1.000 en productos de un pedido '
        'entregado (mínimo 1 punto por pedido). Los puntos se canjean por '
        'cupones de descuento, de valor fijo o porcentaje, que se aplican a '
        'cualquier producto. Cada cupón tiene un límite de canjes y una '
        'vigencia, y por persona solo puede canjearse una vez, salvo que '
        'se reactive. Los puntos y cupones no tienen valor en dinero, no '
        'son transferibles y pueden anularse si detectamos un uso '
        'fraudulento.',
  ),
  TermsSection(
    icon: Icons.description_outlined,
    accent: Color(0xFFE5558A),
    title: 'Limitación de Responsabilidad',
    body: 'La aplicación se provee "tal como está". No garantizamos que el '
        'servicio sea ininterrumpido o libre de errores. No seremos '
        'responsables por daños indirectos, incidentales o consecuentes '
        'derivados del uso de la aplicación o de la imposibilidad de '
        'usarla.',
  ),
];
