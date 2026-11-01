import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Borrador de la bebida de DrinkStudio guardado en el dispositivo, para
/// que no se pierda si la app se cierra o el usuario sale al carrito y
/// vuelve. Solo se restaura si el usuario lo autoriza.
class StudioDraft {
  StudioDraft._();

  static const String _key = 'drinkstudio_draft_v1';

  /// Un borrador más viejo que esto se ignora.
  static const Duration maxAge = Duration(days: 7);

  static Future<void> save(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode({...data, 'savedAt': DateTime.now().toIso8601String()}));
    } catch (_) {
      // Guardar el borrador es un extra: nunca debe romper el estudio.
    }
  }

  static Future<Map<String, dynamic>?> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return null;
      final data = jsonDecode(raw);
      if (data is! Map<String, dynamic>) return null;
      final saved = DateTime.tryParse(data['savedAt']?.toString() ?? '');
      if (saved == null || DateTime.now().difference(saved) > maxAge) {
        await clear();
        return null;
      }
      return data;
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (_) {}
  }
}
