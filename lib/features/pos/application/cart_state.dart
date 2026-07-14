import 'package:yarpay/features/pos/domain/cart_item.dart';

class CartState {
  final List<CartItem> items;

  const CartState({
    this.items = const [],
  });

  double get subtotal =>
      items.fold(0, (sum, item) => sum + item.total);

  int get totalItems =>
      items.fold(0, (sum, item) => sum + item.quantity);

  double get tax => subtotal * 0.05;

  double get total => subtotal + tax;

  CartState copyWith({
    List<CartItem>? items,
  }) {
    return CartState(
      items: items ?? this.items,
    );
  }
}