import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/font_size_provider.dart';
import '../widgets/settings/settings_section_header.dart';
import '../widgets/settings/settings_card_tile.dart';
import '../widgets/settings/settings_dropdown_selector.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedLanguage = 'Español';

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final fontSizeProvider = context.watch<FontSizeProvider>();

    final primaryBrown = const Color(0xFFA2784F);
    final darkBrown = isDark ? const Color(0xFFC3A382) : const Color(0xFF634832);
    final scaffoldBgColor = isDark ? const Color(0xFF1E1410) : const Color(0xFFFAF7F2);

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: darkBrown,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.black : Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configuración',
              style: TextStyle(
                color: isDark ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              'Personaliza tu experiencia',
              style: TextStyle(
                color: isDark ? Colors.black87 : Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        toolbarHeight: 70,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SettingsSectionHeader(title: 'Apariencia'),
            SettingsCardTile(
              icon: isDark ? Icons.nightlight_round : Icons.wb_sunny_outlined,
              title: 'Modo Oscuro',
              subtitle: 'Cambia a tema oscuro',
              trailing: Switch(
                value: isDark,
                activeColor: Colors.white,
                activeTrackColor: primaryBrown,
                onChanged: (val) => themeProvider.toggleTheme(val),
              ),
            ),
            const SizedBox(height: 12),
            SettingsCardTile(
              icon: Icons.remove_red_eye_outlined,
              title: 'Tamaño de Texto',
              subtitle: 'Ajusta el tamaño de la fuente',
              trailing: SettingsDropdownSelector<String>(
                value: fontSizeProvider.fontSize,
                items: const ['Pequeño', 'Mediano', 'Grande'],
                onChanged: (val) {
                  if (val != null) {
                    context.read<FontSizeProvider>().setFontSize(val);
                  }
                },
              ),
            ),
            const SizedBox(height: 24),
            const SettingsSectionHeader(title: 'Idioma'),
            SettingsCardTile(
              icon: Icons.language_rounded,
              title: 'Idioma',
              subtitle: 'Cambiar idioma de la app',
              trailing: SettingsDropdownSelector<String>(
                value: _selectedLanguage,
                items: const ['Español', 'English'],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedLanguage = val);
                },
              ),
            ),
            const SizedBox(height: 24),
            const SettingsSectionHeader(title: 'Privacidad y Seguridad'),
            SettingsCardTile(
              icon: Icons.shield_outlined,
              title: 'Privacidad',
              subtitle: 'Gestiona tus datos',
              trailing: Icon(Icons.arrow_forward_rounded, color: primaryBrown, size: 20),
              onTap: () {},
            ),
            const SizedBox(height: 12),
            SettingsCardTile(
              icon: Icons.lock_outline_rounded,
              title: 'Seguridad',
              subtitle: 'Cambiar contraseña',
              trailing: Icon(Icons.arrow_forward_rounded, color: primaryBrown, size: 20),
              onTap: () {},
            ),
            const SizedBox(height: 24),
            const SettingsSectionHeader(title: 'Soporte'),
            SettingsCardTile(
              icon: Icons.help_outline_rounded,
              title: 'Centro de Ayuda',
              subtitle: 'Preguntas frecuentes',
              trailing: Icon(Icons.arrow_forward_rounded, color: primaryBrown, size: 20),
              onTap: () {},
            ),
            const SizedBox(height: 12),
            SettingsCardTile(
              icon: Icons.description_outlined,
              title: 'Términos y Condiciones',
              subtitle: 'Lee nuestros términos',
              trailing: Icon(Icons.arrow_forward_rounded, color: primaryBrown, size: 20),
              onTap: () {},
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}