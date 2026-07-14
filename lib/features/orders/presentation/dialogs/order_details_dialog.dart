import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:yarpay/features/orders/domain/order.dart';

class OrderDetailsDialog extends StatelessWidget {
  const OrderDetailsDialog({
    super.key,
    required this.order,
  });

  final Order order;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "Order #${order.id.substring(order.id.length - 5)}",
      ),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              _info("Customer", order.customerName.isEmpty
                  ? "Walk-in"
                  : order.customerName),

              _info("Table", order.tableNumber),

              _info("Payment", order.paymentMethod),

              _info(
                "Time",
                DateFormat("dd MMM yyyy • hh:mm a")
                    .format(order.createdAt),
              ),

              const Divider(height: 32),

              const Text(
                "Items",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 10),

              ...order.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [

                      Expanded(
                        child: Text(item.product.name),
                      ),

                      Text("x${item.quantity}"),

                      const SizedBox(width: 20),

                      Text(
                        "₹${(item.product.price * item.quantity).toStringAsFixed(0)}",
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(height: 32),

              _total(
                "Subtotal",
                order.subtotal,
              ),

              _total(
                "GST",
                order.tax,
              ),

              const SizedBox(height: 10),

              _total(
                "Total",
                order.total,
                bold: true,
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
          child: const Text("Close"),
        ),

        FilledButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Receipt printing will be added soon.",
                ),
              ),
            );
          },
          icon: const Icon(Icons.print),
          label: const Text("Print"),
        ),
      ],
    );
  }

  Widget _info(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _total(
    String title,
    double value, {
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [

          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight:
                    bold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),

          Text(
            "₹${value.toStringAsFixed(2)}",
            style: TextStyle(
              fontWeight:
                  bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}