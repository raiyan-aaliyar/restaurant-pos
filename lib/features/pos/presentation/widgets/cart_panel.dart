import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restobill/features/pos/application/cart_provider.dart';
import 'package:restobill/features/pos/presentation/widgets/cart_item_tile.dart';
import 'package:restobill/features/pos/presentation/widgets/cart_summary.dart';
import 'package:restobill/features/pos/presentation/widgets/checkout_button.dart';
import 'package:restobill/features/pos/presentation/dialogs/checkout_dialog.dart';

class CartPanel extends ConsumerWidget {
  const CartPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Current Order",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: cart.items.isEmpty
                  ? const Center(child: Text("Cart is empty"))
                  : ListView.builder(
                      itemCount: cart.items.length,
                      itemBuilder: (context, index) {
                        return CartItemTile(item: cart.items[index]);
                      },
                    ),
            ),

            const Divider(),

            CartSummary( 
              subtotal: cart.subtotal,
              tax: cart.tax,
              total: cart.total,
            ),
            const SizedBox(height: 16),

            CheckoutButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => const CheckoutDialog(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
