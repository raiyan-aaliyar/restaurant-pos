import 'package:flutter/material.dart';

class CartSummary extends StatelessWidget {
  const CartSummary({
    super.key,
    required this.subtotal,
  });

  final double subtotal;

  @override
  Widget build(BuildContext context) {
    final tax = subtotal * 0.05;
    final total = subtotal + tax;

    return Column(
      children: [
        _row("Subtotal", subtotal),
        const SizedBox(height: 8),
        _row("GST (5%)", tax),
        const Divider(height: 24),
        _row(
          "Total",
          total,
          bold: true,
        ),
      ],
    );
  }

  Widget _row(
    String title,
    double value, {
    bool bold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight:
                bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          "₹${value.toStringAsFixed(0)}",
          style: TextStyle(
            fontWeight:
                bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}