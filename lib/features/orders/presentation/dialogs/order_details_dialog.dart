import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import 'package:yarpay/features/orders/data/receipt_service.dart';
import 'package:yarpay/features/orders/domain/order.dart';
import 'package:yarpay/features/orders/application/order_provider.dart';
import 'package:yarpay/features/restaurant/application/restaurant_provider.dart';
import 'package:yarpay/features/settings/application/settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderDetailsDialog extends ConsumerWidget {
  const OrderDetailsDialog({
    super.key,
    required this.order,
  });

  final Order order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurantState = ref.watch(restaurantProvider);
    final isVoided = order.status == 'voided';

    return AlertDialog(
      title: Row(
        children: [
          Expanded(
            child: Text(
              "Order #${order.id.substring(order.id.length - 5)}",
            ),
          ),
          if (isVoided)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'VOIDED',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _info(
                "Customer",
                order.customerName.isEmpty ? "Walk-in" : order.customerName,
              ),
              _info("Table", order.tableNumber),
              _info("Payment", order.paymentMethod),
              _info(
                "Time",
                DateFormat("dd MMM yyyy • hh:mm a").format(order.createdAt),
              ),
              if (isVoided)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 90,
                        child: Text(
                          'Status',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        'VOIDED',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              const Divider(height: 32),
              const Text(
                "Items",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
              _total("Subtotal", order.subtotal),
              if (order.discount > 0)
                _total("Discount", -order.discount, color: Colors.green),
              _total("GST", order.tax),
              const SizedBox(height: 10),
              _total("Total", order.total, bold: true),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),
        if (!isVoided) ...[
          TextButton(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Void Order?'),
                  content: const Text(
                      'This will mark the order as voided. This cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                      child: const Text('Void Order'),
                    ),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                await ref
                    .read(orderProvider.notifier)
                    .voidOrder(order.id);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text("Void Order"),
          ),
          FilledButton.icon(
            onPressed: () async {
              final restaurant = restaurantState.restaurant;
              final settings = ref.read(settingsProvider);
              if (restaurant == null) return;

              final pdfBytes = await ReceiptService.generateReceipt(
                order: order,
                restaurant: restaurant,
                gstEnabled: settings.gstEnabled,
                gstRate: settings.gstRate,
                footer: settings.receiptFooter,
                showAddress: settings.receiptShowAddress,
                showPhone: settings.receiptShowPhone,
              );

              if (context.mounted) {
                await Printing.layoutPdf(
                  onLayout: (format) async => pdfBytes,
                  name: 'Receipt-${order.id.substring(order.id.length - 5)}',
                );
              }
            },
            icon: const Icon(Icons.print),
            label: const Text("Print"),
          ),
          OutlinedButton.icon(
            onPressed: () async {
              final restaurant = restaurantState.restaurant;
              final settings = ref.read(settingsProvider);
              if (restaurant == null) return;

              final pdfBytes = await ReceiptService.generateReceipt(
                order: order,
                restaurant: restaurant,
                gstEnabled: settings.gstEnabled,
                gstRate: settings.gstRate,
                footer: settings.receiptFooter,
                showAddress: settings.receiptShowAddress,
                showPhone: settings.receiptShowPhone,
              );

              await Printing.sharePdf(
                bytes: pdfBytes,
                filename:
                    'receipt-${order.id.substring(order.id.length - 5)}.pdf',
              );
            },
            icon: const Icon(Icons.share),
            label: const Text("Share"),
          ),
        ],
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
              style: const TextStyle(fontWeight: FontWeight.bold),
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
    Color? color,
  }) {
    final displayValue = value < 0
        ? "- ₹${value.abs().toStringAsFixed(2)}"
        : "₹${value.toStringAsFixed(2)}";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            displayValue,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
