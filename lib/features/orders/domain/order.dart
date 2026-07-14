import 'package:yarpay/features/pos/domain/cart_item.dart';

class Order {
  final String id;
  final String customerName;
  final String tableNumber;
  final String paymentMethod;
  final List<CartItem> items;
  final double subtotal;
  final double tax;
  final double total;
  final DateTime createdAt;

  const Order({
    required this.id,
    required this.customerName,
    required this.tableNumber,
    required this.paymentMethod,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.createdAt,
  });
}