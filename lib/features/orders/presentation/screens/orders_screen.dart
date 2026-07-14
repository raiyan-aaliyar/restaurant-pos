import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yarpay/core/widgets/app_scaffold.dart';
import 'package:yarpay/features/orders/application/order_provider.dart';
import 'package:yarpay/features/orders/presentation/widgets/order_card.dart';
import 'package:yarpay/features/orders/presentation/dialogs/order_details_dialog.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(orderProvider);

    return AppScaffold(
      title: 'Orders',
      body: orders.isEmpty
          ? const _EmptyOrdersView()
          : RefreshIndicator(
              onRefresh: () async {
                // Future: Reload orders from database
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders.reversed.toList()[index];

                  return OrderCard(
                    order: order,
onTap: () {
  showDialog(
    context: context,
    builder: (_) => OrderDetailsDialog(
      order: order,
    ),
  );
},
                  );
                },
              ),
            ),
    );
  }
}

class _EmptyOrdersView extends StatelessWidget {
  const _EmptyOrdersView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.receipt_long_rounded,
            size: 90,
            color: Colors.grey,
          ),
          SizedBox(height: 20),
          Text(
            'No Orders Yet',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Completed orders will appear here.',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}