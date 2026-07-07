import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:restobill/data/datasources/fake_data.dart';
import 'package:restobill/domain/entities/product.dart';

import 'category_provider.dart';
import 'search_provider.dart';

final filteredProductsProvider = Provider<List<Product>>((ref) {
  final category = ref.watch(categoryProvider);
  final search = ref.watch(searchProvider).toLowerCase();

  return products.where((product) {
    final matchesCategory =
        category == 'all' || product.categoryId == category;

    final matchesSearch =
        product.name.toLowerCase().contains(search);

    return matchesCategory && matchesSearch;
  }).toList();
});