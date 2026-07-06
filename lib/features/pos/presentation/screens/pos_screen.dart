import 'package:flutter/material.dart';
import 'package:restobill/features/pos/presentation/widgets/category_list.dart';
import 'package:restobill/features/pos/presentation/widgets/product_grid.dart';
import 'package:restobill/features/pos/presentation/widgets/search_section.dart';

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
            const SearchSection(),

            const SizedBox(height: 20),

            CategoryList(),

            const SizedBox(height: 20),

            Expanded(
              child: ProductGrid(
                crossAxisCount: crossAxisCount,
              ),
            ),
          ],
        ),
      ),
    );
  }
}