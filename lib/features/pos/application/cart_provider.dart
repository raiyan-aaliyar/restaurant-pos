import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restobill/domain/entities/product.dart';
import 'package:restobill/features/pos/application/cart_state.dart';
import 'package:restobill/features/pos/domain/cart_item.dart';

final cartProvider =
    NotifierProvider<CartNotifier, CartState>(CartNotifier.new);

class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() {
    return const CartState();
  }

  void addProduct(Product product) {
    final index = state.items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (index != -1) {
      final updatedItems = [...state.items];

      updatedItems[index] = updatedItems[index].copyWith(
        quantity: updatedItems[index].quantity + 1,
      );

      state = state.copyWith(items: updatedItems);
      return;
    }

    state = state.copyWith(
      items: [
        ...state.items,
        CartItem(
          product: product,
          quantity: 1,
        ),
      ],
    );
  }

  void removeProduct(Product product) {
    state = state.copyWith(
      items: state.items
          .where((item) => item.product.id != product.id)
          .toList(),
    );
  }

  void increaseQuantity(Product product) {
    final updatedItems = state.items.map((item) {
      if (item.product.id == product.id) {
        return item.copyWith(
          quantity: item.quantity + 1,
        );
      }
      return item;
    }).toList();

    state = state.copyWith(items: updatedItems);
  }

  void decreaseQuantity(Product product) {
    final updatedItems = <CartItem>[];

    for (final item in state.items) {
      if (item.product.id != product.id) {
        updatedItems.add(item);
        continue;
      }

      if (item.quantity > 1) {
        updatedItems.add(
          item.copyWith(
            quantity: item.quantity - 1,
          ),
        );
      }
    }

    state = state.copyWith(items: updatedItems);
  }

  void clearCart() {
    state = const CartState();
  }
}