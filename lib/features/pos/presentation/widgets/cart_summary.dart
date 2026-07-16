import 'package:flutter/material.dart';
import 'package:yarpay/features/pos/application/cart_state.dart';

class CartSummary extends StatelessWidget {
  const CartSummary({
    super.key,
    required this.subtotal,
    required this.tax,
    required this.total,
    this.gstEnabled = true,
    this.gstRate = 5.0,
    this.discountType = DiscountType.none,
    this.discountAmount = 0,
  });

  final double subtotal;
  final double tax;
  final double total;
  final bool gstEnabled;
  final double gstRate;
  final DiscountType discountType;
  final double discountAmount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _row("Subtotal", subtotal),
        if (discountType != DiscountType.none) ...[
          const SizedBox(height: 8),
          _row("- Discount", -discountAmount, color: Colors.green),
        ],
        if (gstEnabled) ...[
          const SizedBox(height: 8),
          _row("GST (${gstRate.toStringAsFixed(0)}%)", tax),
        ],
        const Divider(height: 24),
        _row("Total", total, bold: true),
      ],
    );
  }

  Widget _row(String title, double value, {bool bold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value < 0
              ? "- ₹${value.abs().toStringAsFixed(0)}"
              : "₹${value.toStringAsFixed(0)}",
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
      ],
    );
  }
}
