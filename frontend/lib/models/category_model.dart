class Category {
  final String id;
  final String name;
  final String description;
  final String image;

  Category({
    required this.id,
    required this.name,
    this.description = '',
    this.image = '',
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      image: json['image'] as String? ?? '',
    );
  }
}
