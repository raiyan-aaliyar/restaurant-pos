import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yarpay/domain/entities/category.dart';
import 'package:yarpay/features/pos/application/category_provider.dart';
import 'package:yarpay/features/pos/application/product_provider.dart';

class CategoryList extends ConsumerWidget {
  const CategoryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(categoryProvider);
    final categories = ref.watch(categoryListProvider);

    final allCategories = [
      const Category(id: 'all', name: 'All'),
      ...categories,
    ];

    return SizedBox(
      height: 45,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: allCategories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = allCategories[index];

          return ChoiceChip(
            label: Text(category.name),
            selected: selected == category.id,
            onSelected: (_) {
              ref.read(categoryProvider.notifier).select(category.id);
            },
          );
        },
      ),
    );
  }
}
