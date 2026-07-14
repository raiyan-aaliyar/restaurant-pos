import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yarpay/data/datasources/fake_data.dart';
import 'package:yarpay/domain/entities/product.dart';

final productProvider = Provider<List<Product>>((ref) {
  return products;
});