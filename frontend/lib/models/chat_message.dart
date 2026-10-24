import 'product_model.dart';

class ChatMessage {
  final String role; // 'user' o 'assistant'
  final String content;

  /// Productos que el asistente recomendó en este mensaje. Vienen del
  /// backend ya validados (datos reales, con promoción vigente) y se
  /// muestran como tarjetas que llevan al detalle del producto.
  final List<Product> products;

  /// El asistente ofreció pasar a WhatsApp: se muestra el botón.
  final bool whatsapp;

  ChatMessage({
    required this.role,
    required this.content,
    this.products = const [],
    this.whatsapp = false,
  });

  bool get isUser => role == 'user';

  /// Crea un mensaje a partir de la respuesta del backend.
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final rawProducts = json['products'];

    return ChatMessage(
      role: json['role'] as String? ?? 'assistant',
      content: (json['content'] ?? json['response'] ?? '') as String,
      whatsapp: json['whatsapp'] == true,
      products: rawProducts is List
          ? rawProducts
              .whereType<Map<String, dynamic>>()
              .map(Product.fromJson)
              .where((p) => p.id.isNotEmpty)
              .toList()
          : const [],
    );
  }
}
