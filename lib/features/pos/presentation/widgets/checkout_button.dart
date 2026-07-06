import 'package:flutter/material.dart';

class CheckoutButton extends StatelessWidget {
  const CheckoutButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            "Checkout",
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}