import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import 'package:yarpay/features/orders/data/receipt_service.dart';
import 'package:yarpay/features/orders/domain/order.dart';
import 'package:yarpay/features/restaurant/application/restaurant_provider.dart';
import 'package:yarpay/features/settings/application/settings_provider.dart';

class OrderCard extends ConsumerWidget {
  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
  });

  final Order order;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurant = ref.watch(restaurantProvider).restaurant;
    final isVoided = order.status == 'voided';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isVoided ? Colors.red.shade50 : null,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor:
              isVoided ? Colors.red.shade100 : null,
          child: Text(
            order.tableNumber.isEmpty ? "T" : order.tableNumber,
            style: isVoided
                ? TextStyle(color: Colors.red.shade700)
                : null,
          ),
        ),
        title: Row(
          children: [
            Text(
              "Order #${order.id.substring(order.id.length - 5)}",
            ),
            if (isVoided) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'VOIDED',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ],
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
              DateFormat("dd MMM yyyy • hh:mm a").format(order.createdAt),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "₹${order.total.toStringAsFixed(0)}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isVoided ? Colors.red : null,
                decoration:
                    isVoided ? TextDecoration.lineThrough : null,
              ),
            ),
            const SizedBox(width: 4),
            if (!isVoided)
              IconButton(
                icon: const Icon(Icons.share, size: 20),
                onPressed: restaurant == null
                    ? null
                    : () async {
                        final settings = ref.read(settingsProvider);
                        final pdfBytes =
                            await ReceiptService.generateReceipt(
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
              ),
          ],
        ),
      ),
    );
  }
}
