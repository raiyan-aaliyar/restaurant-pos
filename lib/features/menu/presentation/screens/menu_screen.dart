import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yarpay/domain/entities/product.dart';
import 'package:yarpay/domain/entities/category.dart';
import 'package:yarpay/features/pos/application/product_provider.dart';
import 'package:yarpay/features/menu/presentation/widgets/add_category_dialog.dart';
import 'package:yarpay/features/menu/presentation/widgets/product_dialog.dart';

class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsState = ref.watch(productsProvider);
    final products = productsState.products;
    final categories = productsState.categories;
    final isLoading = productsState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(productsProvider.notifier).refresh(),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _MenuBody(products: products, categories: categories),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'add_category',
            onPressed: () => showDialog(
              context: context,
              builder: (_) => const AddCategoryDialog(),
            ),
            child: const Icon(Icons.add_rounded),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            heroTag: 'add_product',
            onPressed: () => showDialog(
              context: context,
              builder: (_) => const ProductDialog(),
            ),
            label: const Text('Add Product'),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}

class _MenuBody extends StatelessWidget {
  const _MenuBody({required this.products, required this.categories});

  final List<Product> products;
  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty && products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu_rounded,
              size: 80,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Menu is empty',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Add categories and products to get started.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 900;

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 280,
            child: _CategoryPanel(categories: categories),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: _ProductPanel(products: products, categories: categories),
          ),
        ],
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: _CategoryPanel(categories: categories),
        ),
        const Divider(height: 1),
        Expanded(
          child: _ProductPanel(products: products, categories: categories),
        ),
      ],
    );
  }
}

class _CategoryPanel extends ConsumerWidget {
  const _CategoryPanel({required this.categories});

  final List<Category> categories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Categories (${categories.length})',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: categories.isEmpty
                ? const Center(
                    child: Text(
                      'No categories yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final productCount = ref
                          .watch(productsProvider)
                          .products
                          .where((p) => p.categoryId == category.id)
                          .length;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        child: ListTile(
                          dense: true,
                          leading: const Icon(Icons.folder_rounded, size: 20),
                          title: Text(category.name),
                          subtitle: Text('$productCount products'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18),
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Delete Category'),
                                  content: Text(
                                    'Delete "${category.name}"? Products in this category will not be deleted.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    FilledButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirmed == true && context.mounted) {
                                ref
                                    .read(productsProvider.notifier)
                                    .deleteCategory(category.id);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ProductPanel extends ConsumerWidget {
  const _ProductPanel({
    required this.products,
    required this.categories,
  });

  final List<Product> products;
  final List<Category> categories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Products (${products.length})',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: products.isEmpty
              ? const Center(
                  child: Text(
                    'No products yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final categoryName = categories
                        .where((c) => c.id == product.categoryId)
                        .map((c) => c.name)
                        .firstOrNull ?? 'Unknown';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Text(
                          product.image,
                          style: const TextStyle(fontSize: 28),
                        ),
                        title: Text(
                          product.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '$categoryName · ₹${product.price.toStringAsFixed(0)}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 20),
                              onPressed: () => showDialog(
                                context: context,
                                builder: (_) =>
                                    ProductDialog(product: product),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20),
                              onPressed: () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Delete Product'),
                                    content: Text(
                                        'Delete "${product.name}"?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      FilledButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirmed == true && context.mounted) {
                                  ref
                                      .read(productsProvider.notifier)
                                      .deleteProduct(product.id);
                                }
                              },
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
