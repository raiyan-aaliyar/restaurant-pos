import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yarpay/data/datasources/fake_data.dart';
import 'package:yarpay/features/pos/application/category_provider.dart';

class CategoryList extends ConsumerWidget {
  const CategoryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(categoryProvider);

    return SizedBox(
      height: 45,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = categories[index];

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
