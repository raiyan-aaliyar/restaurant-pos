import 'package:flutter/material.dart';

class CartSummary extends StatelessWidget {
  const CartSummary({
    super.key,
    required this.subtotal,
    required this.tax,
    required this.total,
  });

  final double subtotal;
  final double tax;
  final double total;

  @override
  Widget build(BuildContext context) {
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