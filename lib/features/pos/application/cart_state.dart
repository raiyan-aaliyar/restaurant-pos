import 'package:yarpay/features/pos/domain/cart_item.dart';

enum DiscountType { none, percentage, flat }

class CartState {
  final List<CartItem> items;
  final bool gstEnabled;
  final double gstRate;
  final DiscountType discountType;
  final double discountValue;

  const CartState({
    this.items = const [],
    this.gstEnabled = true,
    this.gstRate = 5.0,
    this.discountType = DiscountType.none,
    this.discountValue = 0,
  });

  double get subtotal =>
      items.fold(0, (sum, item) => sum + item.total);

  int get totalItems =>
      items.fold(0, (sum, item) => sum + item.quantity);

  double get discountAmount {
    if (discountType == DiscountType.percentage) {
      return subtotal * (discountValue / 100);
    } else if (discountType == DiscountType.flat) {
      return discountValue;
    }
    return 0;
  }

  double get discountedSubtotal => subtotal - discountAmount;

  double get tax =>
      gstEnabled ? discountedSubtotal * (gstRate / 100) : 0;

  double get total => discountedSubtotal + tax;

  CartState copyWith({
    List<CartItem>? items,
    bool? gstEnabled,
    double? gstRate,
    DiscountType? discountType,
    double? discountValue,
  }) {
    return CartState(
      items: items ?? this.items,
      gstEnabled: gstEnabled ?? this.gstEnabled,
      gstRate: gstRate ?? this.gstRate,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
    );
  }
}
