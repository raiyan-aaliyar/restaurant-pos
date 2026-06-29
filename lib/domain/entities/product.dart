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
}