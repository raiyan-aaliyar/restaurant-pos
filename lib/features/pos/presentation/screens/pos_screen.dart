import 'package:flutter/material.dart';
import 'package:yarpay/features/pos/presentation/widgets/category_list.dart';
import 'package:yarpay/features/pos/presentation/widgets/product_grid.dart';
import 'package:yarpay/features/pos/presentation/widgets/search_section.dart';
import 'package:yarpay/features/pos/presentation/widgets/cart_panel.dart';

class PosScreen extends StatelessWidget {
  const PosScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
