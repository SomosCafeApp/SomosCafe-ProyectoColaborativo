class AddressItem {
  final String id;
  final String label;
  final String recipientName;
  final String phone;
  final String address;
  final String city;
  final String neighborhood;
  final String additionalInfo;
  final bool isDefault;
  final double? latitude;
  final double? longitude;

  AddressItem({
    required this.id,
    required this.label,
    required this.recipientName,
    required this.phone,
    required this.address,
    required this.city,
    this.neighborhood = '',
    this.additionalInfo = '',
    this.isDefault = false,
    this.latitude,
    this.longitude,
  });

  factory AddressItem.fromJson(Map<String, dynamic> json) {
    return AddressItem(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      label: json['label'] as String? ?? '',
      recipientName: json['recipientName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      neighborhood: json['neighborhood'] as String? ?? '',
      additionalInfo: json['additionalInfo'] as String? ?? '',
      isDefault: json['isDefault'] as bool? ?? false,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  /// Texto corto usado como etiqueta sobre la miniatura de mapa.
  String get mapLabel => label;

  /// Texto secundario mostrado bajo la dirección en la tarjeta.
  String get details {
    final parts = [
      if (neighborhood.isNotEmpty) neighborhood,
      city,
    ];
    return parts.join(', ');
  }
}
