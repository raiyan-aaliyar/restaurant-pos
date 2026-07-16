class Category {
  final String id;
  final String name;
  final int sortOrder;

  const Category({
    required this.id,
    required this.name,
    this.sortOrder = 0,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sort_order': sortOrder,
    };
  }
}
