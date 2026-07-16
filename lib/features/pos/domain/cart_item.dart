import 'package:yarpay/domain/entities/product.dart';

class CartItem {
  final Product product;
  final int quantity;

  const CartItem({
    required this.product,
    required this.quantity,
  });

  double get total => product.price * quantity;

  CartItem copyWith({
    Product? product,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}

class ProductSnapshot implements Product {
  @override
  final String id;
  @override
  final String name;
  @override
  final String categoryId;
  @override
  final double price;
  @override
  final String image;
  @override
  final bool available;

  const ProductSnapshot({
    required this.id,
    required this.name,
    this.categoryId = '',
    required this.price,
    this.image = '🍽️',
    this.available = true,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category_id': categoryId,
      'price': price,
      'image': image,
      'available': available,
    };
  }
}
