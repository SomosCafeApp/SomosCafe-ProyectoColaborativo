import 'package:flutter/material.dart';
import '../widgets/support/whatsapp_button.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../providers/theme_provider.dart';
import '../providers/font_size_provider.dart';
import 'personal_data_page.dart';
import 'security_page.dart';
import 'chat_page.dart';
import '../core/utils/studio_prefs.dart';
import 'terms_page.dart';

import '../widgets/profile/profile_sub_page_header.dart';
import '../widgets/settings/settings_section_header.dart';
import '../widgets/settings/settings_card_tile.dart';
import '../widgets/settings/settings_dropdown_selector.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

  class _SettingsPageState extends State<SettingsPage> {

  @override
  void initState() {
    super.initState();
    StudioPrefs.instance.load();
  }

  @override
  Widget build(BuildContext context) {
    // Provider del tema
    final themeProvider = context.watch<ThemeProvider>();

    // Provider del tamaño de fuente
    final fontSizeProvider = context.watch<FontSizeProvider>();

    final theme = Theme.of(context);
    final primaryBrown = AppColors.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // Header reutilizable
          const ProfileSubPageHeader(
            title: 'Configuración',
            subtitle: 'Personaliza tu experiencia',
          ),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // APARIENCIA

                  const SettingsSectionHeader(
                    title: 'Apariencia',
                  ),

                  SettingsCardTile(
                    icon: Theme.of(context).brightness == Brightness.dark
                        ? Icons.nightlight_round
                        : Icons.wb_sunny_outlined,
                    title: 'Modo Oscuro',
                    subtitle: 'Cambia a tema oscuro',
                    trailing: Switch(
                      // Evaluamos el brillo real del contexto para que refleje si el sistema o la app lo tienen activo
                      value: Theme.of(context).brightness == Brightness.dark,
                      activeThumbColor: Colors.white,
                      activeTrackColor: primaryBrown,
                      onChanged: (value) {
                        // Al hacer clic, cambia el estado en el provider (apaga o enciende el modo oscuro)
                        themeProvider.toggleTheme(value);
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  SettingsCardTile(
                    icon: Icons.remove_red_eye_outlined,
                    title: 'Tamaño de Texto',
                    subtitle: 'Ajusta el tamaño de la fuente',
                    trailing: SettingsDropdownSelector(
                      value: fontSizeProvider.fontSize,
                      items: const [
                        'Pequeño',
                        'Mediano',
                        'Grande',
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          context
                              .read<FontSizeProvider>()
                              .setFontSize(value);
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 24),
                  
                  // ESTUDIO DE BEBIDAS

                  const SettingsSectionHeader(
                    title: 'Estudio de bebidas',
                  ),

                  ListenableBuilder(
                    listenable: StudioPrefs.instance,
                    builder: (context, _) => Column(
                      children: [
                        SettingsCardTile(
                          icon: Icons.vibration_rounded,
                          title: 'Vibración',
                          subtitle: 'Respuesta táctil al preparar tu bebida',
                          trailing: Switch(
                            value: StudioPrefs.instance.haptics,
                            activeThumbColor: Colors.white,
                            activeTrackColor: primaryBrown,
                            onChanged: StudioPrefs.instance.setHaptics,
                          ),
                        ),
                        SettingsCardTile(
                          icon: Icons.auto_awesome_rounded,
                          title: 'Efectos',
                          subtitle: 'Destellos, chorros, nieve y fuego',
                          trailing: Switch(
                            value: StudioPrefs.instance.effects,
                            activeThumbColor: Colors.white,
                            activeTrackColor: primaryBrown,
                            onChanged: StudioPrefs.instance.setEffects,
                          ),
                        ),
                        SettingsCardTile(
                          icon: Icons.animation_rounded,
                          title: 'Animaciones',
                          subtitle: 'Transiciones y movimiento del vaso',
                          trailing: Switch(
                            value: StudioPrefs.instance.animations,
                            activeThumbColor: Colors.white,
                            activeTrackColor: primaryBrown,
                            onChanged: StudioPrefs.instance.setAnimations,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // CUENTA

                  const SettingsSectionHeader(
                    title: 'Cuenta',
                  ),

                  SettingsCardTile(
                    icon: Icons.person_outline_rounded,
                    title: 'Datos Personales',
                    subtitle: 'Nombre, teléfono y cumpleaños',
                    trailing: Icon(
                      Icons.arrow_forward_rounded,
                      color: primaryBrown,
                      size: 20,
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PersonalDataPage()),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // SEGURIDAD

                  const SettingsSectionHeader(
                    title: 'Seguridad',
                  ),

                  SettingsCardTile(
                    icon: Icons.lock_outline_rounded,
                    title: 'Seguridad',
                    subtitle: 'Cambiar contraseña',
                    trailing: Icon(
                      Icons.arrow_forward_rounded,
                      color: primaryBrown,
                      size: 20,
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SecurityPage()),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // SOPORTE

                  const SettingsSectionHeader(
                    title: 'Soporte',
                  ),

                  SettingsCardTile(
                    icon: Icons.help_outline_rounded,
                    title: 'Centro de Ayuda',
                    subtitle: 'Preguntas frecuentes',
                    trailing: Icon(
                      Icons.arrow_forward_rounded,
                      color: primaryBrown,
                      size: 20,
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChatPage()),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SettingsCardTile(
                    icon: Icons.chat_rounded,
                    title: 'Escríbenos por WhatsApp',
                    subtitle: 'Habla con nuestro equipo',
                    trailing: Icon(
                      Icons.arrow_forward_rounded,
                      color: primaryBrown,
                      size: 20,
                    ),
                    onTap: () => openSupportWhatsApp(context),
                  ),

                  const SizedBox(height: 12),

                  SettingsCardTile(
                    icon: Icons.description_outlined,
                    title: 'Términos y Condiciones',
                    subtitle: 'Lee nuestros términos',
                    trailing: Icon(
                      Icons.arrow_forward_rounded,
                      color: primaryBrown,
                      size: 20,
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TermsPage()),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}