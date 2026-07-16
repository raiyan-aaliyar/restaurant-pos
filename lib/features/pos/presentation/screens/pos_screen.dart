import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yarpay/features/pos/application/product_provider.dart';
import 'package:yarpay/features/pos/presentation/widgets/category_list.dart';
import 'package:yarpay/features/pos/presentation/widgets/product_grid.dart';
import 'package:yarpay/features/pos/presentation/widgets/search_section.dart';
import 'package:yarpay/features/pos/presentation/widgets/cart_panel.dart';

class PosScreen extends ConsumerWidget {
  const PosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsState = ref.watch(productsProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    int crossAxisCount = 2;

    if (screenWidth >= 1200) {
      crossAxisCount = 5;
    } else if (screenWidth >= 900) {
      crossAxisCount = 4;
    } else if (screenWidth >= 600) {
      crossAxisCount = 3;
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Restaurant POS',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) {
                      return const SizedBox(height: 600, child: CartPanel());
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final desktop = constraints.maxWidth >= 1100;

            if (desktop) {
              return Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        if (productsState.isUsingCache)
                          const _OfflineBanner(),
                        const SearchSection(),
                        const SizedBox(height: 20),
                        const CategoryList(),
                        const SizedBox(height: 20),
                        Expanded(
                          child: ProductGrid(crossAxisCount: crossAxisCount),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Expanded(child: CartPanel()),
                ],
              );
            }

            return Column(
              children: [
                if (productsState.isUsingCache)
                  const _OfflineBanner(),
                const SearchSection(),
                const SizedBox(height: 20),
                const CategoryList(),
                const SizedBox(height: 20),
                Expanded(child: ProductGrid(crossAxisCount: crossAxisCount)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off_rounded, color: Colors.orange.shade700, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Offline mode - showing cached menu. Changes won\'t sync until online.',
              style: TextStyle(
                color: Colors.orange.shade800,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
