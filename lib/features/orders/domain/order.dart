import 'package:yarpay/features/pos/domain/cart_item.dart';

class Order {
  final String id;
  final String restaurantId;
  final String customerName;
  final String tableNumber;
  final String paymentMethod;
  final List<CartItem> items;
  final double subtotal;
  final double discount;
  final String discountType;
  final double tax;
  final double total;
  final String status;
  final DateTime createdAt;

  const Order({
    required this.id,
    required this.restaurantId,
    required this.customerName,
    required this.tableNumber,
    required this.paymentMethod,
    required this.items,
    required this.subtotal,
    this.discount = 0,
    this.discountType = 'none',
    required this.tax,
    required this.total,
    this.status = 'completed',
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json, {List<CartItem>? items}) {
    return Order(
      id: json['id'] as String,
      restaurantId: json['restaurant_id'] as String,
      customerName: json['customer_name'] as String? ?? '',
      tableNumber: json['table_number'] as String? ?? '',
      paymentMethod: json['payment_method'] as String? ?? 'Cash',
      items: items ?? [],
      subtotal: (json['subtotal'] as num).toDouble(),
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      discountType: json['discount_type'] as String? ?? 'none',
      tax: (json['tax'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      status: json['status'] as String? ?? 'completed',
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_name': customerName,
      'table_number': tableNumber,
      'payment_method': paymentMethod,
      'subtotal': subtotal,
      'discount': discount,
      'discount_type': discountType,
      'tax': tax,
      'total': total,
      'status': status,
    };
  }
}
