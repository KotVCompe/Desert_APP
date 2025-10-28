class Product {
  final int id;
  final String name;
  final String? description;
  final String? fullDescription;
  final double price;
  final int categoryId;
  final String status;
  final int? weightGrams;
  final int? volumeMl;
  final int? calories;
  final List<String> ingredients;
  final List<String> tags;
  final int sortOrder;
  final int purchaseCount;
  final List<ProductImage> images;

  Product({
    required this.id,
    required this.name,
    this.description,
    this.fullDescription,
    required this.price,
    required this.categoryId,
    required this.status,
    this.weightGrams,
    this.volumeMl,
    this.calories,
    required this.ingredients,
    required this.tags,
    required this.sortOrder,
    required this.purchaseCount,
    required this.images,
  });

  String get firstImageUrl => images.isNotEmpty ? images.first.imageUrl : '';

  factory Product.fromJson(Map<String, dynamic> json) {
    print('🔄 Parsing product: ${json['name']}');
    print('📸 Raw images data: ${json['images']}');
    print('📸 Raw images type: ${json['images']?.runtimeType}');

    // Парсим изображения
    List<ProductImage> images = [];
    if (json['images'] != null && json['images'] is List) {
      images = (json['images'] as List).map((imageJson) {
        print('🖼️ Parsing image: $imageJson');
        return ProductImage.fromJson(imageJson);
      }).toList();
    }

    print('✅ Parsed ${images.length} images');

    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Без названия',
      description: json['description'],
      fullDescription: json['fullDescription'] ?? json['full_description'],
      price: (json['price'] is double)
          ? json['price']
          : double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      categoryId: json['category_id'] ?? json['categoryId'] ?? 0,
      status: json['status'] ?? 'active',
      weightGrams: json['weightGrams'] ?? json['weight_grams'],
      volumeMl: json['volumeMl'] ?? json['volume_ml'],
      calories: json['calories'],
      ingredients: List<String>.from(json['ingredients'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      sortOrder: json['sort_order'] ?? json['sortOrder'] ?? 0,
      purchaseCount: json['purchase_count'] ?? json['purchaseCount'] ?? 0,
      images: images,
    );
  }

  // Для отладки
  @override
  String toString() {
    return 'Product{id: $id, name: $name, images: $images}';
  }
}

class ProductImage {
  final int id;
  final int productId;
  final String imageUrl;
  final String? altText;
  final int sortOrder;

  ProductImage({
    required this.id,
    required this.productId,
    required this.imageUrl,
    this.altText,
    required this.sortOrder,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    print('🌐 ProductImage JSON: $json');

    // Обрабатываем разные варианты ключей для imageUrl
    String imageUrl =
        json['imageUrl'] ??
        json['image_url'] ??
        json['url'] ??
        json['image'] ??
        '';

    // Если URL относительный, добавляем базовый URL
    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      // ЗАМЕНИТЕ НА ВАШ БАЗОВЫЙ URL
      imageUrl = 'https://your-api-domain.com$imageUrl';
    }

    print('✅ Final image URL: $imageUrl');

    return ProductImage(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? json['productId'] ?? 0,
      imageUrl: imageUrl,
      altText: json['alt_text'] ?? json['altText'],
      sortOrder: json['sort_order'] ?? json['sortOrder'] ?? 0,
    );
  }

  @override
  String toString() {
    return 'ProductImage{id: $id, url: $imageUrl}';
  }
}
