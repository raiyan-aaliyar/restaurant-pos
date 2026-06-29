import 'package:flutter/material.dart';

import 'package:restobill/core/design/widgets/app_search_bar.dart';
import 'package:restobill/data/datasources/fake_data.dart';
import 'package:restobill/features/pos/presentation/wedgets/product_card.dart';

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
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.dark_mode_outlined),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const AppSearchBar(
              hintText: "Search menu items...",
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 45,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _categoryChip("All"),
                  _categoryChip("Pizza"),
                  _categoryChip("Burger"),
                  _categoryChip("Drinks"),
                  _categoryChip("Desserts"),
                  _categoryChip("Snacks"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: GridView.builder(
                itemCount: products.length,
                gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: .85,
                ),
                itemBuilder: (context, index) {
                  final product = products[index];

                  return ProductCard(
                    product: product,
                    onTap: () {
                      debugPrint("${product.name} tapped");
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryChip(String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Chip(
        label: Text(title),
      ),
    );
  }
}















// class _PosLayout extends StatelessWidget {
//   const _PosLayout({
//     required this.columns,
//     required this.gridAspectRatio,
//   });

//   final int columns;
//   final double gridAspectRatio;

//   @override
//   Widget build(BuildContext context) {
//     return PlaceholderContent(
//       icon: Icons.point_of_sale_rounded,
//       title: 'Point of Sale',
//       description:
//           'Menu grid, cart, and checkout will be implemented here.',
//       children: [
//         Expanded(
//           child: GridView.builder(
//             itemCount: products.length,
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: columns,
//               crossAxisSpacing: 12,
//               mainAxisSpacing: 12,
//               childAspectRatio: gridAspectRatio,
//             ),
//           itemBuilder: (context, index) {
//             return ProductCard(
//               product: products[index],
//               onTap: () {
//                 debugPrint('${products[index].name} tapped');
//               },
//             );
//     },
//           ),
//         ),
//       ],
//     );
//   }
// }
  