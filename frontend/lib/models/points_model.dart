/// Un movimiento del historial de puntos del usuario
/// (GET /api/points/user/:userId/history).
class PointHistoryEntry {
  final String id;
  final int amount; // positivo = ganados, negativo = canjeados
  final String type; // purchase | bonus | redeemed | adjustment
  final String description;
  final DateTime? createdAt;

  PointHistoryEntry({
    required this.id,
    required this.amount,
    required this.type,
    required this.description,
    this.createdAt,
  });

  factory PointHistoryEntry.fromJson(Map<String, dynamic> json) {
    DateTime? createdAt;
    final rawDate = json['createdAt'];
    if (rawDate is String) {
      createdAt = DateTime.tryParse(rawDate);
    }

    return PointHistoryEntry(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      type: json['type'] as String? ?? 'adjustment',
      description: json['description'] as String? ?? '',
      createdAt: createdAt,
    );
  }
}
