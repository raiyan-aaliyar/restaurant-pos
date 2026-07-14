import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yarpay/features/pos/application/cart_provider.dart';
import 'package:yarpay/features/pos/domain/cart_item.dart';

class CartItemTile extends ConsumerWidget {
  const CartItemTile({
    super.key,
    required this.item,
  });

  final CartItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Text(
              item.product.image,
              style: const TextStyle(fontSize: 32),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "₹${item.product.price.toStringAsFixed(0)}",
                  ),
                ],
              ),
            ),

            IconButton(
              onPressed: () {
                ref
                    .read(cartProvider.notifier)
                    .decreaseQuantity(item.product);
              },
              icon: const Icon(Icons.remove_circle_outline),
            ),

            Text(
              item.quantity.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            IconButton(
              onPressed: () {
                ref
                    .read(cartProvider.notifier)
                    .increaseQuantity(item.product);
              },
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ),
    );
  }
}