import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/theme_provider.dart';

import 'help_center_page.dart';
import 'terms_conditions_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedFontSize = 'Mediano';
  String _selectedLanguage = 'Español';

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // Paleta unificada según la app
    const primaryBrown = Color(0xFFA2784F);
    final scaffoldBgColor = isDark
        ? const Color(0xFF1E1410)
        : const Color(0xFFFAF7F2);
    final cardBgColor = isDark ? const Color(0xFF2D211B) : Colors.white;
    final iconBgColor = isDark
        ? const Color(0xFF3D2E26)
        : const Color(0xFFF7F2EB);
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: primaryBrown,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Configuración',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              'Personaliza tu experiencia',
              style: TextStyle(color: Colors.white70, fontSize: 12),
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
            _buildSectionHeader('Apariencia', textColor),

            _buildCardTile(
              cardColor: cardBgColor,
              iconBgColor: iconBgColor,
              textColor: textColor,
              subtitleColor: subtitleColor,
              icon: isDark ? Icons.nightlight_round : Icons.wb_sunny_outlined,
              title: 'Modo Oscuro',
              subtitle: 'Cambia a tema oscuro',
              trailing: Switch(
                value: isDark,
                activeColor: Colors.white,
                activeTrackColor: primaryBrown,
                onChanged: (val) {
                  themeProvider.toggleTheme(val);
                },
              ),
            ),
            const SizedBox(height: 12),

            _buildCardTile(
              cardColor: cardBgColor,
              iconBgColor: iconBgColor,
              textColor: textColor,
              subtitleColor: subtitleColor,
              icon: Icons.remove_red_eye_outlined,
              title: 'Tamaño de Texto',
              subtitle: 'Ajusta el tamaño de la fuente',
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E1410)
                      : const Color(0xFFFAF7F2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? Colors.white24 : Colors.black12,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedFontSize,
                    dropdownColor: cardBgColor,
                    isDense: true,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    items: ['Pequeño', 'Mediano', 'Grande']
                        .map(
                          (val) =>
                              DropdownMenuItem(value: val, child: Text(val)),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedFontSize = val);
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            _buildSectionHeader('Idioma', textColor),
            _buildCardTile(
              cardColor: cardBgColor,
              iconBgColor: iconBgColor,
              textColor: textColor,
              subtitleColor: subtitleColor,
              icon: Icons.language_rounded,
              title: 'Idioma',
              subtitle: 'Cambiar idioma de la app',
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E1410)
                      : const Color(0xFFFAF7F2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? Colors.white24 : Colors.black12,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedLanguage,
                    dropdownColor: cardBgColor,
                    isDense: true,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    items: ['Español', 'English']
                        .map(
                          (val) =>
                              DropdownMenuItem(value: val, child: Text(val)),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedLanguage = val);
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            _buildSectionHeader('Privacidad y Seguridad', textColor),
            _buildCardTile(
              cardColor: cardBgColor,
              iconBgColor: iconBgColor,
              textColor: textColor,
              subtitleColor: subtitleColor,
              icon: Icons.shield_outlined,
              title: 'Privacidad',
              subtitle: 'Gestiona tus datos',
              trailing: Icon(
                Icons.arrow_forward_rounded,
                color: primaryBrown,
                size: 20,
              ),
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _buildCardTile(
              cardColor: cardBgColor,
              iconBgColor: iconBgColor,
              textColor: textColor,
              subtitleColor: subtitleColor,
              icon: Icons.lock_outline_rounded,
              title: 'Seguridad',
              subtitle: 'Cambiar contraseña',
              trailing: Icon(
                Icons.arrow_forward_rounded,
                color: primaryBrown,
                size: 20,
              ),
              onTap: () {},
            ),

            const SizedBox(height: 24),

            _buildSectionHeader('Soporte', textColor),
            _buildCardTile(
              cardColor: cardBgColor,
              iconBgColor: iconBgColor,
              textColor: textColor,
              subtitleColor: subtitleColor,
              icon: Icons.help_outline_rounded,
              title: 'Centro de Ayuda',
              subtitle: 'Preguntas frecuentes',
              trailing: const Icon(
                Icons.arrow_forward_rounded,
                color: primaryBrown,
                size: 20,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HelpCenterPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildCardTile(
              cardColor: cardBgColor,
              iconBgColor: iconBgColor,
              textColor: textColor,
              subtitleColor: subtitleColor,
              icon: Icons.description_outlined,
              title: 'Términos y Condiciones',
              subtitle: 'Lee nuestros términos',
              trailing: const Icon(
                Icons.arrow_forward_rounded,
                color: primaryBrown,
                size: 20,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TermsConditionsPage(),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // --- RECUADRO INFORMATIVO DE LA APP ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF281D17)
                    : const Color(0xFFF9F5EE),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: primaryBrown,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.settings_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Somos CafeApp',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Versión 1.0.0',
                    style: TextStyle(fontSize: 12, color: subtitleColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '© 2026 Somos Cafe. Todos los derechos reservados.',
                    style: TextStyle(
                      fontSize: 11,
                      color: subtitleColor.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildCardTile({
    required Color cardColor,
    required Color iconBgColor,
    required Color textColor,
    required Color subtitleColor,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: const Color(0xFFA2784F), size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: subtitleColor),
        ),
        trailing: trailing,
      ),
    );
  }
}
