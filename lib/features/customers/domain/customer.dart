class Customer {
  final String id;
  final String restaurantId;
  final String name;
  final String phone;
  final String email;
  final String address;
  final String notes;
  final int totalOrders;
  final double totalSpent;
  final DateTime? lastOrderAt;
  final DateTime createdAt;

  const Customer({
    required this.id,
    required this.restaurantId,
    required this.name,
    this.phone = '',
    this.email = '',
    this.address = '',
    this.notes = '',
    this.totalOrders = 0,
    this.totalSpent = 0,
    this.lastOrderAt,
    required this.createdAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String,
      restaurantId: json['restaurant_id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      address: json['address'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      totalOrders: json['total_orders'] as int? ?? 0,
      totalSpent: (json['total_spent'] as num?)?.toDouble() ?? 0,
      lastOrderAt: json['last_order_at'] != null
          ? DateTime.parse(json['last_order_at'] as String).toLocal()
          : null,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'notes': notes,
    };
  }
}
