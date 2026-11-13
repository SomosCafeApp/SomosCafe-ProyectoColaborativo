// GENERADO a partir del contenido oficial del documento. Para cambiar el
// texto edita este archivo directamente (y actualiza la fecha/versión).
import 'package:flutter/material.dart';

import '../app_document.dart';

const AppDocument faqDocument = AppDocument(
  id: 'faq',
  title: 'Preguntas Frecuentes',
  subtitle: 'Respuestas rápidas',
  icon: Icons.quiz_outlined,
  accent: Color(0xFF4A90C2),
  intro: 'Las dudas más comunes de nuestros clientes.',
  meta: 'Versión de la app 1.0.0 · Actualizado: 13 de noviembre de 2026',
  numbered: false,
  sections: [
    DocSection(
      icon: Icons.help_outline_rounded,
      accent: Color(0xFF4A90C2),
      title: '¿A qué zonas hacen domicilios?',
      blocks: [
        DocBlock.p('Solo al casco urbano de Garzón, Huila. El domicilio cuesta \$5.000; recoger en el local es gratis.'),
      ],
    ),
    DocSection(
      icon: Icons.help_outline_rounded,
      accent: Color(0xFF2FA36B),
      title: '¿Cómo pago?',
      blocks: [
        DocBlock.p('En efectivo (al domiciliario o en la cafetería) o por transferencia con el QR de la cafetería, subiendo la captura del comprobante.'),
      ],
    ),
    DocSection(
      icon: Icons.help_outline_rounded,
      accent: Color(0xFFE07B39),
      title: '¿Puedo cancelar mi pedido?',
      blocks: [
        DocBlock.p('Sí, desde Perfil > Historial de Pedidos con el botón Cancelar, mientras esté Pendiente o Confirmado y dentro de los 10 minutos que indica el contador. Después, escríbenos por WhatsApp.'),
      ],
    ),
    DocSection(
      icon: Icons.help_outline_rounded,
      accent: Color(0xFFF2A81D),
      title: 'Mi comprobante fue invalidado, ¿qué hago?',
      blocks: [
        DocBlock.p('Te llega una notificación y el pedido se cancela. Puedes hacer un pedido nuevo y pagar de nuevo, o escribirnos por WhatsApp con tu comprobante para revisarlo.'),
      ],
    ),
    DocSection(
      icon: Icons.help_outline_rounded,
      accent: Color(0xFF8B6CD9),
      title: '¿Cómo funcionan los puntos?',
      blocks: [
        DocBlock.p('Ganas 1 punto por cada \$1.000 en productos de un pedido entregado (mínimo 1). Los canjeas por cupones en Perfil > Recompensas.'),
      ],
    ),
    DocSection(
      icon: Icons.help_outline_rounded,
      accent: Color(0xFFE5558A),
      title: '¿Por qué no me llega el correo de verificación?',
      blocks: [
        DocBlock.p('Revisa spam o correo no deseado y espera un par de minutos. En la pantalla de verificación puedes pedir un código nuevo. Verifica que escribiste bien tu correo.'),
      ],
    ),
    DocSection(
      icon: Icons.help_outline_rounded,
      accent: Color(0xFF2A9D8F),
      title: '¿El ChatBot puede hacer mi pedido?',
      blocks: [
        DocBlock.p('Puede armar el carrito con lo que le pidas, pero el pedido solo se hace cuando tú lo confirmas. Revisa siempre el resumen.'),
      ],
    ),
    DocSection(
      icon: Icons.help_outline_rounded,
      accent: Color(0xFFE53935),
      title: 'Tengo una alergia, ¿qué hago?',
      blocks: [
        DocBlock.p('Avísale al personal antes de pedir. No podemos garantizar la ausencia de trazas de alérgenos en nuestros productos.'),
      ],
    ),
    DocSection(
      icon: Icons.help_outline_rounded,
      accent: Color(0xFFB7791F),
      title: '¿Cómo cambio mi contraseña o mis datos?',
      blocks: [
        DocBlock.p('En Perfil > Configuración: Seguridad para la contraseña y Datos personales para nombre, teléfono y cumpleaños.'),
      ],
    ),
    DocSection(
      icon: Icons.help_outline_rounded,
      accent: Color(0xFF4A90C2),
      title: '¿Cómo contacto a la cafetería?',
      blocks: [
        DocBlock.p('Desde Configuración > Soporte: Centro de Ayuda (ChatBot) o WhatsApp. También por correo a legal@coffeeapp.co.'),
      ],
    ),
  ],
);
