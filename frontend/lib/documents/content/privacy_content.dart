// GENERADO a partir del contenido oficial del documento. Para cambiar el
// texto edita este archivo directamente (y actualiza la fecha/versión).
import 'package:flutter/material.dart';

import '../app_document.dart';

const AppDocument privacyDocument = AppDocument(
  id: 'privacy',
  title: 'Política de Privacidad',
  subtitle: 'Tratamiento de datos personales',
  icon: Icons.privacy_tip_outlined,
  accent: Color(0xFF8B6CD9),
  intro: 'Tu privacidad nos importa. Aquí te explicamos qué datos tratamos, para qué, con quién los compartimos y cómo ejercer tus derechos, conforme a la Ley 1581 de 2012 (protección de datos personales) y el Decreto 1377 de 2013, compilado en el Decreto 1074 de 2015.',
  meta: 'Versión 2026-11-13 · Última actualización: 13 de noviembre de 2026',
  numbered: true,
  sections: [
    DocSection(
      icon: Icons.storefront_outlined,
      accent: Color(0xFFB7791F),
      title: 'Responsable del tratamiento',
      blocks: [
        DocBlock.p('Cafetería SOMOS, con sede en Garzón, Huila, Colombia, es la responsable del tratamiento de tus datos personales a través de SomosCafe App.\nCorreo para asuntos de datos: legal@coffeeapp.co'),
      ],
    ),
    DocSection(
      icon: Icons.list_alt_rounded,
      accent: Color(0xFF4A90C2),
      title: 'Qué datos recopilamos',
      blocks: [
        DocBlock.ul([
          'Cuenta: nombre, apellido, correo electrónico, contraseña (guardada cifrada, nunca en texto) y, si los das, teléfono y fecha de cumpleaños.',
          'Perfil: avatar elegido o foto de perfil (de tu galería o, si entras con Google, la de tu cuenta de Google).',
          'Entrega: direcciones, barrio, indicaciones adicionales, nombre y teléfono del destinatario, y el punto que eliges en el mapa.',
          'Pedidos: productos, personalizaciones, valores, tipo de entrega, método de pago, estado e historial.',
          'Comprobantes de pago: la imagen que subes cuando pagas por transferencia.',
          'Actividad en la app: favoritos, reseñas, puntos, cupones, notificaciones y partidas guardadas de DrinkStudio.',
          'ChatBot: los mensajes que escribes o dictas y las respuestas.',
          'Técnicos: token de notificaciones del dispositivo y registros mínimos del servidor necesarios para seguridad y funcionamiento.',
        ]),
        DocBlock.note('No recopilamos tu ubicación GPS: las direcciones las escribes tú o las marcas en el mapa. No grabamos ni guardamos audio. No mostramos publicidad ni usamos rastreadores publicitarios.'),
      ],
    ),
    DocSection(
      icon: Icons.flag_outlined,
      accent: Color(0xFF2FA36B),
      title: 'Para qué usamos tus datos',
      blocks: [
        DocBlock.ul([
          'Crear y administrar tu cuenta y verificar tu correo.',
          'Recibir, preparar, cobrar y entregar tus pedidos, y validar pagos por transferencia.',
          'Enviarte avisos del estado de tus pedidos y de tu cuenta.',
          'Gestionar puntos, cupones, promociones, eventos y reseñas.',
          'Atenderte por el ChatBot y por soporte (WhatsApp).',
          'Enviarte, si lo permites, notificaciones de promociones, productos nuevos y eventos.',
          'Prevenir fraude y abusos, mantener la seguridad y mejorar el servicio.',
          'Cumplir obligaciones legales, contables y tributarias.',
        ]),
      ],
    ),
    DocSection(
      icon: Icons.verified_user_outlined,
      accent: Color(0xFF4A90C2),
      title: 'Tu autorización',
      blocks: [
        DocBlock.p('Tratamos tus datos con tu autorización previa, expresa e informada, que das al aceptar estos documentos al crear tu cuenta (o al continuar con Google). Guardamos constancia de la fecha y de la versión que aceptaste. Puedes revocarla o pedir la supresión de tus datos en cualquier momento, salvo cuando exista un deber legal o contractual de conservarlos.'),
      ],
    ),
    DocSection(
      icon: Icons.child_care_rounded,
      accent: Color(0xFFE5558A),
      title: 'Niños, niñas y adolescentes',
      blocks: [
        DocBlock.p('La app está dirigida a mayores de 18 años. No tratamos intencionalmente datos de menores sin la autorización de sus padres o representantes legales. Si crees que un menor se registró sin autorización, escríbenos y eliminaremos su cuenta.'),
      ],
    ),
    DocSection(
      icon: Icons.hub_outlined,
      accent: Color(0xFF8B6CD9),
      title: 'Con quién compartimos los datos',
      blocks: [
        DocBlock.p('No vendemos tus datos. Usamos proveedores que los tratan por encargo nuestro y solo para prestar el servicio:'),
        DocBlock.ul([
          'Google: inicio de sesión, notificaciones push (Firebase Cloud Messaging), mapas y geocodificación de direcciones.',
          'MongoDB Atlas: base de datos donde se guarda la información de la app.',
          'Render: alojamiento del servidor (backend) de la app.',
          'Cloudinary: almacenamiento de imágenes (fotos de perfil, productos, eventos y comprobantes de pago).',
          'Brevo: envío de correos de verificación y recuperación de contraseña.',
          'Groq: procesamiento de los mensajes del ChatBot para generar respuestas.',
          'WhatsApp (Meta): solo si tú decides escribirnos por ese canal.',
        ]),
        DocBlock.p('Algunos de estos proveedores pueden almacenar o procesar información fuera de Colombia (transferencia internacional). Al aceptar esta política autorizas esa transferencia, y exigimos a los proveedores niveles adecuados de protección. También podemos entregar datos a autoridades cuando una ley o una orden judicial lo exija.'),
        DocBlock.p('El personal autorizado de la cafetería accede a la información necesaria para atender pedidos (por ejemplo nombre, teléfono, dirección y comprobante).'),
      ],
    ),
    DocSection(
      icon: Icons.phone_android_rounded,
      accent: Color(0xFF2A9D8F),
      title: 'Permisos del teléfono',
      blocks: [
        DocBlock.ul([
          'Internet: necesario para usar la app.',
          'Notificaciones: para avisos de pedidos y novedades. Puedes negarlas o quitarlas en los ajustes del teléfono.',
          'Micrófono: solo si usas el dictado por voz del ChatBot. El reconocimiento lo hace el servicio de voz de tu teléfono; la app no guarda el audio.',
          'Fotos y cámara: solo cuando eliges una foto de perfil o un comprobante; se usa el selector del sistema.',
          'Guardar en galería: para guardar el código QR de pago (en Android 9 o inferior puede pedir acceso al almacenamiento).',
        ]),
      ],
    ),
    DocSection(
      icon: Icons.security_rounded,
      accent: Color(0xFF2FA36B),
      title: 'Seguridad',
      blocks: [
        DocBlock.p('Aplicamos medidas técnicas y administrativas razonables: contraseñas cifradas, comunicaciones cifradas (HTTPS), acceso restringido por roles, verificación de correo y límites contra abusos. Ningún sistema es 100 % infalible; si detectamos un incidente que afecte tus datos, actuaremos y te informaremos según la ley.'),
      ],
    ),
    DocSection(
      icon: Icons.timer_outlined,
      accent: Color(0xFFF2A81D),
      title: 'Cuánto tiempo conservamos los datos',
      blocks: [
        DocBlock.p('Conservamos tus datos mientras tengas tu cuenta. Los mensajes del ChatBot y la información operativa se conservan solo el tiempo necesario para el servicio. Al eliminar tu cuenta borramos tus datos personales (ver más abajo). Algunos registros de ventas pueden conservarse, sin datos que te identifiquen, por el tiempo que exijan las normas contables y tributarias.'),
      ],
    ),
    DocSection(
      icon: Icons.gpp_good_outlined,
      accent: Color(0xFF4A90C2),
      title: 'Tus derechos como titular',
      blocks: [
        DocBlock.ul([
          'Conocer, actualizar y rectificar tus datos.',
          'Pedir prueba de tu autorización.',
          'Ser informado del uso que se le ha dado a tus datos.',
          'Presentar quejas ante la Superintendencia de Industria y Comercio (SIC) por infracciones a la ley.',
          'Revocar la autorización y solicitar la supresión de tus datos.',
          'Acceder de forma gratuita a tus datos personales.',
        ]),
        DocBlock.p('Para ejercerlos puedes editar tus datos en Configuración > Datos personales, eliminar tu cuenta desde la app, o escribir a legal@coffeeapp.co indicando tu nombre y el correo de tu cuenta. Responderemos las consultas en máximo 10 días hábiles y los reclamos en máximo 15 días hábiles, prorrogables según el artículo 14 y el artículo 15 de la Ley 1581 de 2012.'),
      ],
    ),
    DocSection(
      icon: Icons.delete_outline_rounded,
      accent: Color(0xFFE53935),
      title: 'Eliminación de cuenta y datos',
      blocks: [
        DocBlock.p('Desde Configuración > Datos personales > Eliminar cuenta puedes borrar tu cuenta (sin pedidos en curso). Al hacerlo:'),
        DocBlock.ul([
          'Se eliminan tus direcciones, carrito, chats, tokens de notificaciones, favoritos, notificaciones, puntos, cupones, métodos de pago guardados y tu foto de perfil.',
          'Tu cuenta queda anonimizada: se borran nombre, correo, teléfono, fecha de cumpleaños y el vínculo con Google.',
          'En tus pedidos anteriores se eliminan el nombre, teléfono y dirección de entrega y el comprobante de pago; se conservan solo los montos y productos para fines contables.',
        ]),
        DocBlock.p('Si no puedes entrar a la app, pide la eliminación escribiendo a legal@coffeeapp.co desde el correo de tu cuenta.'),
      ],
    ),
    DocSection(
      icon: Icons.update_rounded,
      accent: Color(0xFF2A9D8F),
      title: 'Cambios a esta política',
      blocks: [
        DocBlock.p('Podemos actualizar esta política. Publicaremos la nueva versión en la app con su fecha y, si el cambio es importante, te lo avisaremos y pediremos de nuevo tu autorización cuando la ley lo exija.'),
      ],
    ),
    DocSection(
      icon: Icons.mail_outline_rounded,
      accent: Color(0xFFB7791F),
      title: 'Contacto',
      blocks: [
        DocBlock.p('Cafetería SOMOS · Garzón, Huila, Colombia\nCorreo: legal@coffeeapp.co'),
      ],
    ),
  ],
);
