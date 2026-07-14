import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:yarpay/features/orders/domain/order.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
  });

  final Order order;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,

        leading: CircleAvatar(
          child: Text(
            order.tableNumber.isEmpty
                ? "T"
                : order.tableNumber,
          ),
        ),

        title: Text(
          "Order #${order.id.substring(order.id.length - 5)}",
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              order.customerName.isEmpty
                  ? "Walk-in Customer"
                  : order.customerName,
            ),

            Text(
              DateFormat(
                "dd MMM yyyy • hh:mm a",
              ).format(order.createdAt),
            ),
          ],
        ),

        trailing: Text(
          "₹${order.total.toStringAsFixed(0)}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}