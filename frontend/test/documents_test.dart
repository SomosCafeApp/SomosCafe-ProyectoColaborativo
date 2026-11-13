import 'package:flutter_test/flutter_test.dart';
import 'package:somoscafeapp/core/config/app_info.dart';
import 'package:somoscafeapp/documents/documents_registry.dart';

void main() {
  test('los documentos tienen id único y contenido', () {
    final ids = appDocuments.map((d) => d.id).toList();
    expect(ids.toSet().length, ids.length);
    for (final doc in appDocuments) {
      expect(doc.title, isNotEmpty);
      expect(doc.sections, isNotEmpty, reason: doc.id);
      for (final s in doc.sections) {
        expect(s.title, isNotEmpty);
        expect(s.blocks, isNotEmpty, reason: '${doc.id}: ${s.title}');
      }
    }
  });

  test('los documentos obligatorios existen', () {
    final ids = appDocuments.map((d) => d.id).toSet();
    expect(
      ids,
      containsAll(<String>[
        'terms',
        'privacy',
        'user_manual',
        'install_manual',
        'delete_account',
      ]),
    );
  });

  test('la versión de los términos coincide con la de AppInfo', () {
    expect(termsDocument.meta, contains(AppInfo.termsVersion));
    expect(privacyDocument.meta, contains(AppInfo.termsVersion));
  });
}
