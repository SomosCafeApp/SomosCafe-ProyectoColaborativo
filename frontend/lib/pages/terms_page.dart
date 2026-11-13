import 'package:flutter/material.dart';

import '../documents/document_viewer_page.dart';
import '../documents/documents_registry.dart';

/// Términos y Condiciones. El texto vive en
/// `documents/content/terms_content.dart` y se muestra con el visor
/// genérico de documentos (el mismo de Configuración > Documentos).
class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) =>
      const DocumentViewerPage(document: termsDocument);
}
