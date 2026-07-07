import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restobill/features/pos/application/cart_provider.dart';
import 'package:restobill/features/orders/application/order_provider.dart';
import 'package:restobill/features/orders/domain/order.dart';

class CheckoutDialog extends ConsumerStatefulWidget {
  const CheckoutDialog({super.key});

  @override
  ConsumerState<CheckoutDialog> createState() =>
      _CheckoutDialogState();
}

class _CheckoutDialogState
    extends ConsumerState<CheckoutDialog> {
  String paymentMethod = "Cash";

  final customerController = TextEditingController();
  final tableController = TextEditingController();

  @override
  void dispose() {
    customerController.dispose();
    tableController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);

    return AlertDialog(
      title: const Text("Checkout"),

      content: SizedBox(
        width: 450,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              TextField(
                controller: customerController,
                decoration: const InputDecoration(
                  labelText: "Customer Name (Optional)",
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: tableController,
                decoration: const InputDecoration(
                  labelText: "Table Number",
                ),
              ),

              const SizedBox(height: 24),

              DropdownButtonFormField<String>(
                initialValue: paymentMethod,
                decoration: const InputDecoration(
                  labelText: "Payment Method",
                ),
                items: const [
                  DropdownMenuItem(
                    value: "Cash",
                    child: Text("Cash"),
                  ),
                  DropdownMenuItem(
                    value: "Card",
                    child: Text("Card"),
                  ),
                  DropdownMenuItem(
                    value: "UPI",
                    child: Text("UPI"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    paymentMethod = value!;
                  });
                },
              ),

              const SizedBox(height: 24),

              const Divider(),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Subtotal"),
                  Text("₹${cart.subtotal.toStringAsFixed(0)}"),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  const Text("GST"),
                  Text("₹${cart.tax.toStringAsFixed(0)}"),
                ],
              ),

              const Divider(),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Grand Total",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "₹${cart.total.toStringAsFixed(0)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      actions: [

        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancel"),
        ),

        FilledButton(
onPressed: () {
  final cart = ref.read(cartProvider);

  final order = Order(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    customerName: customerController.text,
    tableNumber: tableController.text,
    paymentMethod: paymentMethod,
    items: List.from(cart.items),
    subtotal: cart.subtotal,
    tax: cart.tax,
    total: cart.total,
    createdAt: DateTime.now(),
  );

  ref.read(orderProvider.notifier).addOrder(order);

  ref.read(cartProvider.notifier).clearCart();

  Navigator.pop(context);

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Order placed successfully"),
    ),
  );
},          child: const Text("Confirm Order"),
        ),
      ],
    );
  }
}