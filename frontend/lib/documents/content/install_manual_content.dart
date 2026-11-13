// GENERADO a partir del contenido oficial del documento. Para cambiar el
// texto edita este archivo directamente (y actualiza la fecha/versión).
import 'package:flutter/material.dart';

import '../app_document.dart';

const AppDocument installManualDocument = AppDocument(
  id: 'install_manual',
  title: 'Manual de Instalación',
  subtitle: 'Instala y actualiza la app',
  icon: Icons.download_rounded,
  accent: Color(0xFF2FA36B),
  intro: 'Cómo instalar, actualizar y desinstalar SomosCafe App en tu teléfono Android.',
  meta: 'Versión de la app 1.0.0 · Actualizado: 13 de noviembre de 2026',
  numbered: false,
  sections: [
    DocSection(
      icon: Icons.phone_android_rounded,
      accent: Color(0xFF2FA36B),
      title: 'Requisitos',
      blocks: [
        DocBlock.ul([
          'Teléfono Android 7.0 o superior.',
          'Conexión a internet (datos móviles o Wi-Fi).',
          'Cuenta de Google en el teléfono (para Google Play y, si quieres, para iniciar sesión).',
          'Unos 100 MB libres de almacenamiento.',
        ]),
      ],
    ),
    DocSection(
      icon: Icons.shop_two_outlined,
      accent: Color(0xFF4A90C2),
      title: 'Instalar desde Google Play (recomendado)',
      blocks: [
        DocBlock.ul([
          'Abre Google Play Store en tu teléfono.',
          'Busca SomosCafe App o el nombre de la cafetería SOMOS.',
          'Toca Instalar y espera a que termine.',
          'Toca Abrir, o busca el ícono de SomosCafe en tu pantalla.',
        ]),
        DocBlock.note('Instalar desde la tienda oficial garantiza que recibes la versión original y las actualizaciones automáticas.'),
      ],
    ),
    DocSection(
      icon: Icons.folder_open_rounded,
      accent: Color(0xFFE07B39),
      title: 'Instalar con el archivo APK (alternativa)',
      blocks: [
        DocBlock.ul([
          'Descarga el archivo .apk solo desde el enlace o código QR oficial de la cafetería (sección Releases del proyecto).',
          'Ábrelo desde Descargas. Si el teléfono lo pide, permite Instalar apps de fuentes desconocidas solo para ese navegador o administrador de archivos.',
          'Toca Instalar. Si Google Play Protect muestra una advertencia, elige Instalar de todos modos (solo si descargaste el archivo del enlace oficial).',
          'Al terminar, vuelve a desactivar el permiso de fuentes desconocidas.',
        ]),
        DocBlock.note('La versión de Google Play y la del APK pueden estar firmadas con claves distintas: no se pueden instalar una encima de otra. Si cambias de una a otra, desinstala primero la anterior.'),
      ],
    ),
    DocSection(
      icon: Icons.check_circle_outline_rounded,
      accent: Color(0xFF8B6CD9),
      title: 'Primer uso y permisos',
      blocks: [
        DocBlock.ul([
          'Crea tu cuenta o entra con Google (ver Manual de Usuario).',
          'Notificaciones: acepta el permiso para recibir avisos de tus pedidos.',
          'Micrófono: solo si quieres dictar al ChatBot.',
          'Fotos: el selector del teléfono te pedirá acceso cuando elijas una foto de perfil o un comprobante.',
        ]),
        DocBlock.p('La primera vez que abres la app tras un rato sin usarla, la conexión con el servidor puede tardar hasta un minuto en responder. Espera un momento y vuelve a intentar.'),
      ],
    ),
    DocSection(
      icon: Icons.system_update_rounded,
      accent: Color(0xFF2A9D8F),
      title: 'Actualizar la app',
      blocks: [
        DocBlock.p('Con Google Play: abre la ficha de la app y toca Actualizar, o activa las actualizaciones automáticas. Con APK: descarga la versión nueva del mismo enlace oficial e instálala encima (sin desinstalar). Tus datos están en tu cuenta, no en el teléfono.'),
      ],
    ),
    DocSection(
      icon: Icons.build_circle_outlined,
      accent: Color(0xFFF2A81D),
      title: 'Solución de problemas',
      blocks: [
        DocBlock.ul([
          'No se instala: libera espacio, reinicia el teléfono y vuelve a intentar; verifica que tu Android sea 7.0 o superior.',
          'No carga el menú o los pedidos: revisa tu internet y espera unos segundos; el servidor puede estar despertando.',
          'No llegan notificaciones: permite las notificaciones de la app en los ajustes del teléfono y desactiva el ahorro de batería para SomosCafe.',
          'No entra con Google: verifica que haya una cuenta de Google en el teléfono, actualiza Google Play Services y la app.',
          'No cargan los mapas: revisa tu conexión; el mapa necesita internet.',
          'Cualquier otro problema: escríbenos por WhatsApp desde Configuración > Soporte.',
        ]),
      ],
    ),
    DocSection(
      icon: Icons.delete_outline_rounded,
      accent: Color(0xFFE53935),
      title: 'Desinstalar',
      blocks: [
        DocBlock.p('Mantén presionado el ícono de la app y elige Desinstalar, o ve a Ajustes > Aplicaciones > SomosCafe > Desinstalar. Desinstalar la app no borra tu cuenta; para eliminarla usa Configuración > Datos personales > Eliminar cuenta antes de desinstalar.'),
      ],
    ),
  ],
);
