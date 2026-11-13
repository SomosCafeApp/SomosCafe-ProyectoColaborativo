import 'package:flutter/material.dart';

import '../animations/animations.dart';
import '../core/constants/app_colors.dart';
import '../widgets/profile/profile_sub_page_header.dart';
import 'app_document.dart';

/// Abre un documento a pantalla completa.
Future<void> openDocument(BuildContext context, AppDocument document) {
  return Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => DocumentViewerPage(document: document)),
  );
}

/// Visor genérico de documentos: encabezado, índice desplegable y
/// secciones en tarjetas. Lo usan manuales, términos y políticas.
class DocumentViewerPage extends StatefulWidget {
  final AppDocument document;

  const DocumentViewerPage({super.key, required this.document});

  @override
  State<DocumentViewerPage> createState() => _DocumentViewerPageState();
}

class _DocumentViewerPageState extends State<DocumentViewerPage> {
  late final List<GlobalKey> _keys =
      List.generate(widget.document.sections.length, (_) => GlobalKey());

  void _jumpTo(int index) {
    final ctx = _keys[index].currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      alignment: 0.02,
    );
  }

  @override
  Widget build(BuildContext context) {
    final doc = widget.document;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          ProfileSubPageHeader(title: doc.title, subtitle: doc.subtitle),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              // Espacio abajo para que la barra de navegación no tape el final.
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 6),
                    child: Text(
                      doc.meta,
                      style: TextStyle(fontSize: 12, color: muted),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, right: 4, bottom: 16),
                    child: Text(
                      doc.intro,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (doc.sections.length > 3) ...[
                    _IndexCard(document: doc, onTap: _jumpTo),
                    const SizedBox(height: 16),
                  ],
                  for (var i = 0; i < doc.sections.length; i++) ...[
                    _SectionCard(
                      key: _keys[i],
                      number: doc.numbered ? i + 1 : null,
                      section: doc.sections[i],
                    ),
                    const SizedBox(height: 16),
                  ],
                  Center(
                    child: Text(
                      '© 2026 SOMOS CafeApp · Garzón, Huila',
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

/// Índice desplegable: toca un título para saltar a esa sección.
class _IndexCard extends StatelessWidget {
  final AppDocument document;
  final ValueChanged<int> onTap;

  const _IndexCard({required this.document, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardTheme.color ??
        (isDark ? AppColors.darkSurface : AppColors.lightSurface);
    final textColor = theme.colorScheme.onSurface;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        // Quita las líneas divisorias por defecto del ExpansionTile.
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
          leading: const Icon(Icons.list_alt_rounded, color: AppColors.primary),
          title: Text(
            'Contenido',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          children: [
            for (var i = 0; i < document.sections.length; i++)
              ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                onTap: () => onTap(i),
                title: Text(
                  document.numbered
                      ? '${i + 1}. ${document.sections[i].title}'
                      : document.sections[i].title,
                  style: TextStyle(fontSize: 13, color: textColor),
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Tarjeta de una sección: icono en burbuja de color, título y bloques.
class _SectionCard extends StatelessWidget {
  final int? number;
  final DocSection section;

  const _SectionCard({super.key, required this.number, required this.section});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardTheme.color ??
        (isDark ? AppColors.darkSurface : AppColors.lightSurface);
    final titleColor = theme.colorScheme.onSurface;
    final bodyColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return SoftFadeIn(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: section.accent
                        .withValues(alpha: isDark ? 0.22 : 0.16),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(section.icon, color: section.accent, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    number == null ? section.title : '$number. ${section.title}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            for (final block in section.blocks)
              _BlockView(
                block: block,
                bodyColor: bodyColor,
                accent: section.accent,
                isDark: isDark,
              ),
          ],
        ),
      ),
    );
  }
}

class _BlockView extends StatelessWidget {
  final DocBlock block;
  final Color bodyColor;
  final Color accent;
  final bool isDark;

  const _BlockView({
    required this.block,
    required this.bodyColor,
    required this.accent,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontSize: 13.5, height: 1.55, color: bodyColor);

    switch (block.type) {
      case DocBlockType.paragraph:
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(block.text, style: style),
        );

      case DocBlockType.bullets:
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final item in block.items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 7, right: 10),
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Expanded(child: Text(item, style: style)),
                    ],
                  ),
                ),
            ],
          ),
        );

      case DocBlockType.note:
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: isDark ? 0.14 : 0.10),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: accent.withValues(alpha: 0.30)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, size: 18, color: accent),
              const SizedBox(width: 10),
              Expanded(child: Text(block.text, style: style)),
            ],
          ),
        );
    }
  }
}
