import 'package:flutter/material.dart';

/// Tipos de bloque de texto dentro de una sección de un documento.
enum DocBlockType { paragraph, bullets, note }

/// Un bloque: párrafo, lista con viñetas o nota destacada.
class DocBlock {
  final DocBlockType type;
  final String text;
  final List<String> items;

  const DocBlock.p(this.text)
      : type = DocBlockType.paragraph,
        items = const [];

  const DocBlock.ul(this.items)
      : type = DocBlockType.bullets,
        text = '';

  const DocBlock.note(this.text)
      : type = DocBlockType.note,
        items = const [];
}

/// Una sección de un documento (con su icono de color y su contenido).
class DocSection {
  final IconData icon;
  final Color accent;
  final String title;
  final List<DocBlock> blocks;

  const DocSection({
    required this.icon,
    required this.accent,
    required this.title,
    required this.blocks,
  });
}

/// Un documento de la app: manual, términos, política, etc.
class AppDocument {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final String intro;

  /// Línea de versión/fecha que se muestra bajo el título.
  final String meta;

  /// Si es true, las secciones se numeran (1., 2., ...).
  final bool numbered;
  final List<DocSection> sections;

  const AppDocument({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.intro,
    required this.meta,
    required this.numbered,
    required this.sections,
  });
}
