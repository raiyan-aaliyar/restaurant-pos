import 'package:flutter/material.dart';
import 'package:restobill/core/widgets/app_scaffold.dart';
import 'package:restobill/core/widgets/placeholder_content.dart';
import 'package:restobill/core/widgets/responsive_builder.dart';

/// Orders management screen placeholder.
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Orders',
      body: ResponsiveBuilder(
        mobile: const _OrdersLayout(itemCount: 4),
        tablet: const _OrdersLayout(itemCount: 6),
        largeTablet: const _OrdersLayout(itemCount: 8),
      ),
    );
  }
}

class _OrdersLayout extends StatelessWidget {
  const _OrdersLayout({required this.itemCount});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return PlaceholderContent(
      icon: Icons.receipt_long_rounded,
      title: 'Orders',
      description:
          'Active, completed, and cancelled orders will be listed here.',
      children: [
        Expanded(
          child: ListView.separated(
            itemCount: itemCount,
            separatorBuilder: (context, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Text('${index + 1}'),
                  ),
                  title: Text('Order #${1000 + index}'),
                  subtitle: const Text('Placeholder order entry'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
