import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restobill/features/pos/application/cart_provider.dart';
import 'package:restobill/features/pos/application/filtered_product_provider.dart';
import 'package:restobill/features/pos/presentation/widgets/product_card.dart';

class ProductGrid extends ConsumerWidget {
  const ProductGrid({
    super.key,
    required this.crossAxisCount,
  });

  final int crossAxisCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(filteredProductsProvider);

    return GridView.builder(
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: .85,
      ),
      itemBuilder: (context, index) {
        final product = products[index];

        return ProductCard(
          product: product,
          onTap: () {
            ref.read(cartProvider.notifier).addProduct(product);
          },
        );
      },
    );
  }
}