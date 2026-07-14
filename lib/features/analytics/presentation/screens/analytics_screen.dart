import 'package:flutter/material.dart';
import 'package:yarpay/core/widgets/app_scaffold.dart';
import 'package:yarpay/core/widgets/placeholder_content.dart';
import 'package:yarpay/core/widgets/responsive_builder.dart';

/// Analytics dashboard screen placeholder.
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Analytics',
      body: ResponsiveBuilder(
        mobile: const _AnalyticsLayout(columns: 1),
        tablet: const _AnalyticsLayout(columns: 2),
        largeTablet: const _AnalyticsLayout(columns: 3),
      ),
    );
  }
}

class _AnalyticsLayout extends StatelessWidget {
  const _AnalyticsLayout({required this.columns});

  final int columns;

  @override
  Widget build(BuildContext context) {
    final metrics = [
      ('Revenue', Icons.payments_rounded),
      ('Orders', Icons.shopping_bag_rounded),
      ('Avg. Ticket', Icons.receipt_rounded),
      ('Top Item', Icons.star_rounded),
      ('Peak Hour', Icons.schedule_rounded),
      ('Customers', Icons.people_rounded),
    ];

    return PlaceholderContent(
      icon: Icons.insights_rounded,
      title: 'Analytics',
      description:
          'Sales metrics, trends, and reports will be displayed here.',
      children: [
        Expanded(
          child: GridView.builder(
            itemCount: metrics.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: columns == 1 ? 2.8 : 1.6,
            ),
            itemBuilder: (context, index) {
              final (label, icon) = metrics[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const Spacer(),
                      Text(
                        label,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '—',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
