import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yarpay/data/services/supabase_service.dart';
import 'package:yarpay/features/analytics/application/analytics_provider.dart';
import 'package:yarpay/features/orders/domain/order.dart';
import 'package:yarpay/features/pos/domain/cart_item.dart';
import 'package:yarpay/features/pos/application/cart_state.dart';
import 'package:yarpay/features/restaurant/application/restaurant_provider.dart';

class OrderNotifier extends Notifier<List<Order>> {
  @override
  List<Order> build() {
    final restaurantId = ref.watch(restaurantIdProvider);

    if (restaurantId != null) {
      _loadOrders();
    }

    return [];
  }

  Future<void> _loadOrders() async {
    try {
      final response = await SupabaseService.client.rpc('get_orders');
      final list = (response as List<dynamic>? ?? []).map((json) {
        final map = json as Map<String, dynamic>;
        final itemsData = map['items'] as List<dynamic>? ?? [];
        final items = itemsData.map((item) {
          return CartItem(
            product: ProductSnapshot(
              id: item['product_id'] as String,
              name: item['product_name'] as String,
              price: (item['price'] as num).toDouble(),
            ),
            quantity: item['quantity'] as int,
          );
        }).toList();
        return Order.fromJson(map, items: items);
      }).toList();
      state = list;
    } catch (e) {
      state = [];
    }
  }

  Future<void> refresh() async {
    await _loadOrders();
  }

  Future<Order?> addOrder({
    required String customerName,
    required String tableNumber,
    required String paymentMethod,
    required CartState cart,
  }) async {
    try {
      final items = cart.items.map((item) {
        return {
          'product_id': item.product.id,
          'product_name': item.product.name,
          'price': item.product.price,
          'quantity': item.quantity,
        };
      }).toList();

      await SupabaseService.client.rpc('create_order', params: {
        'p_customer_name': customerName,
        'p_table_number': tableNumber,
        'p_payment_method': paymentMethod,
        'p_subtotal': cart.subtotal,
        'p_discount': cart.discountAmount,
        'p_discount_type': cart.discountType.name,
        'p_tax': cart.tax,
        'p_total': cart.total,
        'p_items': items,
      });

      await refresh();

      ref.invalidate(analyticsProvider);

      final createdOrder = Order(
        id: state.isNotEmpty ? state.first.id : '',
        restaurantId: state.isNotEmpty ? state.first.restaurantId : '',
        customerName: customerName,
        tableNumber: tableNumber,
        paymentMethod: paymentMethod,
        items: cart.items.toList(),
        subtotal: cart.subtotal,
        discount: cart.discountAmount,
        discountType: cart.discountType.name,
        tax: cart.tax,
        total: cart.total,
        status: 'completed',
        createdAt: DateTime.now(),
      );

      return createdOrder;
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteOrder(String orderId) async {
    try {
      await SupabaseService.client.rpc('delete_order', params: {
        'p_id': orderId,
      });
      await refresh();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> voidOrder(String orderId) async {
    try {
      await SupabaseService.client.rpc('void_order', params: {
        'p_id': orderId,
      });
      await refresh();
      ref.invalidate(analyticsProvider);
      return true;
    } catch (e) {
      return false;
    }
  }
}

final orderProvider = NotifierProvider<OrderNotifier, List<Order>>(
  OrderNotifier.new,
);
