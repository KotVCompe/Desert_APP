class Category {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? json['category_id'] ?? 0,
      name: json['name'] ?? json['category_name'] ?? 'Без названия',
      imageUrl: json['imageUrl'] ?? json['image_url'] ?? json['image'],
      description: json['description'] ?? json['category_description'],
    );
  }
}
