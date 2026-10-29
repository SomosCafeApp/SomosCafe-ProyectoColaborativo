import 'product_model.dart';

/// Atajo que el asistente sugiere debajo de su respuesta (por ejemplo
/// los tamaños disponibles, «Sí, agregar» o «Cancelar»).
class ChatQuickReply {
  final String label;
  final String text;

  const ChatQuickReply({required this.label, required this.text});

  static List<ChatQuickReply> listFrom(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map((m) => ChatQuickReply(
              label: (m['label'] ?? '').toString(),
              text: (m['text'] ?? m['label'] ?? '').toString(),
            ))
        .where((q) => q.label.isNotEmpty && q.text.isNotEmpty)
        .toList();
  }
}

/// Línea de una propuesta de carrito (datos calculados por el servidor).
class ChatPendingLine {
  final String name;
  final int quantity;
  final List<String> options;
  final double unitPrice;
  final double originalUnitPrice;
  final double lineTotal;
  final String promotionName;

  const ChatPendingLine({
    required this.name,
    required this.quantity,
    required this.options,
    required this.unitPrice,
    required this.originalUnitPrice,
    required this.lineTotal,
    required this.promotionName,
  });

  factory ChatPendingLine.fromJson(Map<String, dynamic> json) => ChatPendingLine(
        name: json['name'] as String? ?? '',
        quantity: (json['quantity'] as num?)?.toInt() ?? 1,
        options: (json['options'] as List? ?? const []).map((e) => e.toString()).toList(),
        unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
        originalUnitPrice: (json['originalUnitPrice'] as num?)?.toDouble() ?? 0,
        lineTotal: (json['lineTotal'] as num?)?.toDouble() ?? 0,
        promotionName: json['promotionName'] as String? ?? '',
      );
}

/// Acción que el asistente PROPONE y que solo se ejecuta si el cliente
/// la confirma (agregar al carrito o vaciarlo). El servidor es quien
/// valida y calcula los importes; esta clase solo los muestra.
class ChatPendingAction {
  final String id;
  final String type; // ADD_TO_CART | CLEAR_CART
  final List<ChatPendingLine> items;
  final double total;

  const ChatPendingAction({
    required this.id,
    required this.type,
    required this.items,
    required this.total,
  });

  bool get isClearCart => type == 'CLEAR_CART';

  static ChatPendingAction? fromJson(dynamic raw) {
    if (raw is! Map<String, dynamic>) return null;
    final id = raw['id'] as String? ?? '';
    if (id.isEmpty) return null;

    return ChatPendingAction(
      id: id,
      type: raw['type'] as String? ?? 'ADD_TO_CART',
      total: (raw['total'] as num?)?.toDouble() ?? 0,
      items: (raw['items'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ChatPendingLine.fromJson)
          .toList(),
    );
  }
}

class ChatMessage {
  final String role; // 'user' o 'assistant'
  final String content;

  /// Productos que el asistente recomendó en este mensaje. Vienen del
  /// backend ya validados (datos reales, con promoción vigente) y se
  /// muestran como tarjetas con botones para elegir, ver detalle o agregar.
  final List<Product> products;

  /// El asistente ofreció pasar a WhatsApp: se muestra el botón.
  final bool whatsapp;

  /// Atajos sugeridos para responder con un toque.
  final List<ChatQuickReply> quickReplies;

  /// Propuesta de carrito esperando confirmación (solo la del último
  /// mensaje es accionable).
  final ChatPendingAction? pending;

  /// El asistente pide abrir el carrito (nunca paga ni crea pedidos).
  final bool openCart;

  /// Es una respuesta recién llegada (se muestra escribiéndose).
  final bool isFresh;

  /// Mensaje de error local (no viene del servidor): permite reintentar.
  final bool isError;

  const ChatMessage({
    required this.role,
    required this.content,
    this.products = const [],
    this.whatsapp = false,
    this.quickReplies = const [],
    this.pending,
    this.openCart = false,
    this.isFresh = false,
    this.isError = false,
  });

  bool get isUser => role == 'user';

  ChatMessage copyWith({bool? isFresh, ChatPendingAction? pending, bool clearPending = false}) =>
      ChatMessage(
        role: role,
        content: content,
        products: products,
        whatsapp: whatsapp,
        quickReplies: quickReplies,
        pending: clearPending ? null : (pending ?? this.pending),
        openCart: openCart,
        isFresh: isFresh ?? this.isFresh,
        isError: isError,
      );

  /// Crea un mensaje a partir de la respuesta del backend.
  factory ChatMessage.fromJson(Map<String, dynamic> json, {bool fresh = false}) {
    final rawProducts = json['products'];
    final actions = json['actions'];

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
      quickReplies: ChatQuickReply.listFrom(json['quickReplies']),
      pending: ChatPendingAction.fromJson(json['pendingAction']),
      openCart: actions is List &&
          actions.whereType<Map<String, dynamic>>().any((a) => a['type'] == 'open_cart'),
      isFresh: fresh,
    );
  }
}
