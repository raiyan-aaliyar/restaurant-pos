import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yarpay/data/services/supabase_service.dart';
import 'package:yarpay/domain/entities/category.dart';
import 'package:yarpay/domain/entities/product.dart';
import 'package:yarpay/features/restaurant/application/restaurant_provider.dart';

class ProductsState {
  final List<Product> products;
  final List<Category> categories;
  final bool isLoading;
  final bool isUsingCache;
  final String? error;

  const ProductsState({
    this.products = const [],
    this.categories = const [],
    this.isLoading = false,
    this.isUsingCache = false,
    this.error,
  });

  ProductsState copyWith({
    List<Product>? products,
    List<Category>? categories,
    bool? isLoading,
    bool? isUsingCache,
    String? error,
    bool clearError = false,
  }) {
    return ProductsState(
      products: products ?? this.products,
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      isUsingCache: isUsingCache ?? this.isUsingCache,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ProductsNotifier extends Notifier<ProductsState> {
  @override
  ProductsState build() {
    final restaurantId = ref.watch(restaurantIdProvider);

    if (restaurantId != null) {
      _loadProducts();
      _loadCategories();
    }

    return const ProductsState(isLoading: true);
  }

  Future<void> _loadProducts() async {
    try {
      final response = await SupabaseService.client.rpc('get_products');
      final list = (response as List<dynamic>? ?? [])
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
      state = state.copyWith(products: list, isUsingCache: false, clearError: true);
      await _cacheProducts(list);
    } catch (e) {
      final cached = await _loadCachedProducts();
      if (cached.isNotEmpty) {
        state = state.copyWith(
          products: cached,
          isUsingCache: true,
          clearError: true,
        );
      } else {
        state = state.copyWith(error: 'Failed to load products.');
      }
    }
  }

  Future<void> _loadCategories() async {
    try {
      final response = await SupabaseService.client.rpc('get_categories');
      final list = (response as List<dynamic>? ?? [])
          .map((json) => Category.fromJson(json as Map<String, dynamic>))
          .toList();
      state = state.copyWith(categories: list, clearError: true);
      await _cacheCategories(list);
    } catch (e) {
      final cached = await _loadCachedCategories();
      if (cached.isNotEmpty) {
        state = state.copyWith(categories: cached, clearError: true);
      } else {
        state = state.copyWith(error: 'Failed to load categories.');
      }
    }
  }

  Future<void> _cacheProducts(List<Product> products) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = products.map((p) => jsonEncode({
        'id': p.id,
        'name': p.name,
        'category_id': p.categoryId,
        'price': p.price,
        'image': p.image,
        'available': p.available,
      })).toList();
      await prefs.setStringList('cache_products', json);
    } catch (_) {}
  }

  Future<void> _cacheCategories(List<Category> categories) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = categories.map((c) => jsonEncode({
        'id': c.id,
        'name': c.name,
        'sort_order': c.sortOrder,
      })).toList();
      await prefs.setStringList('cache_categories', json);
    } catch (_) {}
  }

  Future<List<Product>> _loadCachedProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getStringList('cache_products') ?? [];
      return json.map((s) {
        final map = jsonDecode(s) as Map<String, dynamic>;
        return Product.fromJson(map);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Category>> _loadCachedCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getStringList('cache_categories') ?? [];
      return json.map((s) {
        final map = jsonDecode(s) as Map<String, dynamic>;
        return Category.fromJson(map);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await _loadProducts();
    await _loadCategories();
    state = state.copyWith(isLoading: false);
  }

  Future<bool> addProduct(Product product) async {
    try {
      await SupabaseService.client.rpc('add_product', params: {
        'p_name': product.name,
        'p_category_id': product.categoryId,
        'p_price': product.price,
        'p_image': product.image,
        'p_available': product.available,
      });
      await refresh();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to add product.');
      return false;
    }
  }

  Future<bool> updateProduct(Product product) async {
    try {
      await SupabaseService.client.rpc('update_product', params: {
        'p_id': product.id,
        'p_name': product.name,
        'p_category_id': product.categoryId,
        'p_price': product.price,
        'p_image': product.image,
        'p_available': product.available,
      });
      await refresh();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to update product.');
      return false;
    }
  }

  Future<bool> deleteProduct(String productId) async {
    try {
      await SupabaseService.client.rpc('delete_product', params: {
        'p_id': productId,
      });
      await refresh();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete product.');
      return false;
    }
  }

  Future<bool> addCategory(Category category) async {
    try {
      await SupabaseService.client.rpc('add_category', params: {
        'p_name': category.name,
        'p_sort_order': category.sortOrder,
      });
      await refresh();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to add category.');
      return false;
    }
  }

  Future<bool> deleteCategory(String categoryId) async {
    try {
      await SupabaseService.client.rpc('delete_category', params: {
        'p_id': categoryId,
      });
      await refresh();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete category.');
      return false;
    }
  }
}

final productsProvider =
    NotifierProvider<ProductsNotifier, ProductsState>(
  ProductsNotifier.new,
);

final productListProvider = Provider<List<Product>>((ref) {
  return ref.watch(productsProvider).products;
});

final categoryListProvider = Provider<List<Category>>((ref) {
  return ref.watch(productsProvider).categories;
});
