/// Estado de un evento visto desde el panel admin.
enum AppEventStatus { active, inactive, ended }

extension AppEventStatusX on AppEventStatus {
  String get label {
    switch (this) {
      case AppEventStatus.active:
        return 'Activo (pop-up)';
      case AppEventStatus.inactive:
        return 'Inactivo';
      case AppEventStatus.ended:
        return 'Finalizado';
    }
  }
}

/// Evento del café (GET /events, GET /events/active).
class AppEvent {
  final String id;
  final String name;
  final String description;
  final String image;
  final String location;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  const AppEvent({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  bool get hasImage => image.startsWith('http');

  bool get hasEnded => endDate.isBefore(DateTime.now());

  bool get hasStarted => !startDate.isAfter(DateTime.now());

  AppEventStatus get status {
    if (hasEnded) return AppEventStatus.ended;
    return isActive ? AppEventStatus.active : AppEventStatus.inactive;
  }

  /// "12/10/2026" o "12/10/2026 → 14/10/2026" si dura más de un día.
  String get dateRangeText {
    String fmt(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

    final sameDay = startDate.year == endDate.year &&
        startDate.month == endDate.month &&
        startDate.day == endDate.day;

    return sameDay ? fmt(startDate) : '${fmt(startDate)} → ${fmt(endDate)}';
  }

  factory AppEvent.fromJson(Map<String, dynamic> json) {
    return AppEvent(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      image: json['image'] as String? ?? '',
      location: json['location'] as String? ?? '',
      startDate: DateTime.tryParse(json['startDate'] as String? ?? '')?.toLocal() ?? DateTime.now(),
      endDate: DateTime.tryParse(json['endDate'] as String? ?? '')?.toLocal() ?? DateTime.now(),
      isActive: json['isActive'] as bool? ?? false,
    );
  }
}
