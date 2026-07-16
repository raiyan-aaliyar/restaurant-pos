class Product {
  final String id;
  final String name;
  final String categoryId;
  final double price;
  final String image;
  final bool available;

  const Product({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.price,
    required this.image,
    this.available = true,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      categoryId: json['category_id'] as String,
      price: (json['price'] as num).toDouble(),
      image: json['image'] as String? ?? '🍽️',
      available: json['available'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category_id': categoryId,
      'price': price,
      'image': image,
      'available': available,
    };
  }
}
