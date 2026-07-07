import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restobill/data/datasources/fake_data.dart';
import 'package:restobill/domain/entities/product.dart';

final productProvider = Provider<List<Product>>((ref) {
  return products;
});