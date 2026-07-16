import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:yarpay/features/orders/data/receipt_service.dart';
import 'package:yarpay/features/pos/application/cart_provider.dart';
import 'package:yarpay/features/pos/application/cart_state.dart';
import 'package:yarpay/features/orders/application/order_provider.dart';
import 'package:yarpay/features/restaurant/application/restaurant_provider.dart';
import 'package:yarpay/features/settings/application/settings_provider.dart';

class PaymentSplit {
  String method;
  double amount;

  PaymentSplit({required this.method, required this.amount});
}

class CheckoutDialog extends ConsumerStatefulWidget {
  const CheckoutDialog({super.key});

  @override
  ConsumerState<CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends ConsumerState<CheckoutDialog> {
  bool _isSubmitting = false;
  bool _splitMode = false;
  final List<PaymentSplit> _splits = [PaymentSplit(method: "Cash", amount: 0)];

  final customerController = TextEditingController();
  final tableController = TextEditingController();
  final discountController = TextEditingController();

  @override
  void dispose() {
    customerController.dispose();
    tableController.dispose();
    discountController.dispose();
    super.dispose();
  }

  String _buildPaymentString(CartState cart) {
    if (!_splitMode) {
      return _splits.first.method;
    }
    return _splits
        .where((s) => s.amount > 0)
        .map((s) => '${s.method}: ${s.amount.toStringAsFixed(0)}')
        .join(' + ');
  }

  Future<void> _handleCheckout({required bool printReceipt}) async {
    setState(() => _isSubmitting = true);

    final cart = ref.read(cartProvider);

    if (_splitMode) {
      final splitTotal = _splits.fold(0.0, (sum, s) => sum + s.amount);
      if ((splitTotal - cart.total).abs() > 1) {
        setState(() => _isSubmitting = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Split total (₹${splitTotal.toStringAsFixed(0)}) must equal order total (₹${cart.total.toStringAsFixed(0)})',
              ),
            ),
          );
        }
        return;
      }
    }

    final paymentString = _buildPaymentString(cart);

    final order = await ref.read(orderProvider.notifier).addOrder(
          customerName: customerController.text,
          tableNumber: tableController.text,
          paymentMethod: paymentString,
          cart: cart,
        );

    if (!mounted) return;

    if (order != null) {
      ref.read(cartProvider.notifier).clearCart();
      Navigator.pop(context);

      if (printReceipt) {
        final restaurant = ref.read(restaurantProvider).restaurant;
        final settings = ref.read(settingsProvider);
        if (restaurant != null) {
          final pdfBytes = await ReceiptService.generateReceipt(
            order: order,
            restaurant: restaurant,
            gstEnabled: settings.gstEnabled,
            gstRate: settings.gstRate,
            footer: settings.receiptFooter,
            showAddress: settings.receiptShowAddress,
            showPhone: settings.receiptShowPhone,
          );
          await Printing.layoutPdf(
            onLayout: (format) async => pdfBytes,
            name: 'Receipt-${order.id.substring(order.id.length - 5)}',
          );
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order placed successfully")),
      );
    } else {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Failed to place order. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    if (_splits.isEmpty) {
      _splits.add(PaymentSplit(method: "Cash", amount: cart.total));
    }

    final splitTotal = _splits.fold(0.0, (sum, s) => sum + s.amount);
    final remaining = cart.total - splitTotal;

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
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Split Payment"),
                subtitle: Text(
                  _splitMode
                      ? "Pay with multiple methods"
                      : "Single payment method",
                ),
                value: _splitMode,
                onChanged: (value) {
                  setState(() {
                    _splitMode = value;
                    if (_splitMode && _splits.isEmpty) {
                      _splits
                          .add(PaymentSplit(method: "Cash", amount: cart.total));
                    }
                  });
                },
              ),
              if (!_splitMode)
                DropdownButtonFormField<String>(
                  initialValue: _splits.first.method,
                  decoration: const InputDecoration(
                    labelText: "Payment Method",
                  ),
                  items: const [
                    DropdownMenuItem(value: "Cash", child: Text("Cash")),
                    DropdownMenuItem(value: "Card", child: Text("Card")),
                    DropdownMenuItem(value: "UPI", child: Text("UPI")),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _splits.first.method = value);
                    }
                  },
                )
              else ...[
                ...List.generate(_splits.length, (index) {
                  final split = _splits[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            initialValue: split.method,
                            decoration: const InputDecoration(
                              labelText: "Method",
                              isDense: true,
                            ),
                            items: const [
                              DropdownMenuItem(
                                  value: "Cash", child: Text("Cash")),
                              DropdownMenuItem(
                                  value: "Card", child: Text("Card")),
                              DropdownMenuItem(
                                  value: "UPI", child: Text("UPI")),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => split.method = value);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "Amount (₹)",
                              isDense: true,
                            ),
                            controller: TextEditingController(
                              text: split.amount > 0
                                  ? split.amount.toStringAsFixed(0)
                                  : '',
                            ),
                            onChanged: (value) {
                              setState(() {
                                split.amount = double.tryParse(value) ?? 0;
                              });
                            },
                          ),
                        ),
                        if (_splits.length > 1)
                          IconButton(
                            icon: const Icon(Icons.remove_circle,
                                color: Colors.red, size: 20),
                            onPressed: () {
                              setState(() => _splits.removeAt(index));
                            },
                          ),
                      ],
                    ),
                  );
                }),
                if (remaining > 1)
                  Text(
                    'Remaining: ₹${remaining.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: remaining > 0 ? Colors.orange : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _splits
                          .add(PaymentSplit(method: "Cash", amount: remaining > 0 ? remaining : 0));
                    });
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Add Payment Method"),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<DiscountType>(
                      initialValue: cart.discountType,
                      decoration: const InputDecoration(
                        labelText: "Discount",
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: DiscountType.none, child: Text("None")),
                        DropdownMenuItem(
                            value: DiscountType.percentage,
                            child: Text("% Off")),
                        DropdownMenuItem(
                            value: DiscountType.flat,
                            child: Text("₹ Off")),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          cartNotifier.setDiscount(value, cart.discountValue);
                        }
                      },
                    ),
                  ),
                  if (cart.discountType != DiscountType.none) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: discountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText:
                              cart.discountType == DiscountType.percentage
                                  ? '%'
                                  : '₹',
                        ),
                        onChanged: (value) {
                          final v = double.tryParse(value) ?? 0;
                          cartNotifier.setDiscount(cart.discountType, v);
                        },
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Subtotal"),
                  Text("₹${cart.subtotal.toStringAsFixed(0)}"),
                ],
              ),
              if (cart.discountType != DiscountType.none) ...[
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Discount${cart.discountType == DiscountType.percentage ? ' (${cart.discountValue.toStringAsFixed(0)}%)' : ''}",
                    ),
                    Text(
                      "- ₹${cart.discountAmount.toStringAsFixed(0)}",
                      style: const TextStyle(color: Colors.green),
                    ),
                  ],
                ),
              ],
              if (cart.gstEnabled) ...[
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("GST (${cart.gstRate.toStringAsFixed(0)}%)"),
                    Text("₹${cart.tax.toStringAsFixed(0)}"),
                  ],
                ),
              ],
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Grand Total",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "₹${cart.total.toStringAsFixed(0)}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        OutlinedButton.icon(
          onPressed:
              _isSubmitting ? null : () => _handleCheckout(printReceipt: false),
          icon: _isSubmitting
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.shopping_cart),
          label: const Text("Place Order"),
        ),
        FilledButton.icon(
          onPressed:
              _isSubmitting ? null : () => _handleCheckout(printReceipt: true),
          icon: const Icon(Icons.print),
          label: const Text("Print & Place"),
        ),
      ],
    );
  }
}
