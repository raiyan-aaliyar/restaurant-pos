import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yarpay/domain/entities/product.dart';
import 'package:yarpay/features/pos/application/category_provider.dart';
import 'package:yarpay/features/pos/application/product_provider.dart';
import 'package:yarpay/features/pos/application/search_provider.dart';

final filteredProductsProvider = Provider<List<Product>>((ref) {
  final products = ref.watch(productListProvider);
  final search = ref.watch(searchProvider).toLowerCase();
  final category = ref.watch(categoryProvider);

  return products.where((product) {
    final matchesSearch =
        product.name.toLowerCase().contains(search);
    final matchesCategory =
        category == 'all' || product.categoryId == category;
    return matchesSearch && matchesCategory;
  }).toList();
});
