import 'app_document.dart';
import 'content/terms_content.dart';
import 'content/privacy_content.dart';
import 'content/user_manual_content.dart';
import 'content/install_manual_content.dart';
import 'content/delete_account_content.dart';
import 'content/faq_content.dart';

export 'app_document.dart';
export 'content/terms_content.dart' show termsDocument;
export 'content/privacy_content.dart' show privacyDocument;

/// Documentos que se listan en Configuración > Documentos, en este orden.
const List<AppDocument> appDocuments = [
  userManualDocument,
  installManualDocument,
  termsDocument,
  privacyDocument,
  faqDocument,
  deleteAccountDocument,
];
