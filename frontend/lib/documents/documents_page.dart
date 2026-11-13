import 'package:flutter/material.dart';

import '../core/config/app_info.dart';
import '../core/constants/app_colors.dart';
import '../widgets/profile/profile_sub_page_header.dart';
import '../widgets/settings/settings_card_tile.dart';
import '../widgets/settings/settings_section_header.dart';
import 'document_viewer_page.dart';
import 'documents_registry.dart';

/// Configuración → Documentos: índice de los documentos de interés de la
/// app (manuales, términos, política de privacidad, etc.).
class DocumentsPage extends StatelessWidget {
  const DocumentsPage({super.key});

  static const _guideIds = ['user_manual', 'install_manual', 'faq'];
  static const _legalIds = ['terms', 'privacy', 'delete_account'];

  List<AppDocument> _byIds(List<String> ids) => [
        for (final id in ids)
          for (final d in appDocuments)
            if (d.id == id) d,
      ];

  Widget _tile(BuildContext context, AppDocument doc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SettingsCardTile(
        icon: doc.icon,
        title: doc.title,
        subtitle: doc.subtitle,
        trailing: const Icon(
          Icons.arrow_forward_rounded,
          color: AppColors.primary,
          size: 20,
        ),
        onTap: () => openDocument(context, doc),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          const ProfileSubPageHeader(
            title: 'Documentos',
            subtitle: 'Manuales, términos y políticas',
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SettingsSectionHeader(title: 'Guías'),
                  for (final d in _byIds(_guideIds)) _tile(context, d),
                  const SizedBox(height: 12),
                  const SettingsSectionHeader(title: 'Legal y privacidad'),
                  for (final d in _byIds(_legalIds)) _tile(context, d),
                  const SizedBox(height: 12),
                  const SettingsSectionHeader(title: 'Acerca de'),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SettingsCardTile(
                      icon: Icons.code_rounded,
                      title: 'Licencias de código abierto',
                      subtitle: 'Librerías que hacen posible la app',
                      trailing: const Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      onTap: () => showLicensePage(
                        context: context,
                        applicationName: AppInfo.appName,
                        applicationVersion: AppInfo.version,
                        applicationLegalese: '© 2026 SOMOS CafeApp',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      '${AppInfo.appName} · versión ${AppInfo.version} (${AppInfo.build})',
                      style: TextStyle(fontSize: 12, color: muted),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
