class Restaurant {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String logoUrl;
  final DateTime createdAt;

  const Restaurant({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.logoUrl,
    required this.createdAt,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      logoUrl: json['logo_url'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'phone': phone,
      'logo_url': logoUrl,
    };
  }
}

class UserProfile {
  final String id;
  final String userId;
  final String restaurantId;
  final String fullName;
  final String role;
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.userId,
    required this.restaurantId,
    required this.fullName,
    required this.role,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      restaurantId: json['restaurant_id'] as String,
      fullName: json['full_name'] as String? ?? '',
      role: json['role'] as String? ?? 'cashier',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  bool get isOwner => role == 'owner';
  bool get isManager => role == 'manager';
  bool get isCashier => role == 'cashier';
  bool get canManageMenu => isOwner || isManager;
  bool get canViewAnalytics => isOwner || isManager;
}
