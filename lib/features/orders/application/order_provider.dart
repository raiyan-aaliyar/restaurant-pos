import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yarpay/features/orders/domain/order.dart';

final orderProvider =
    NotifierProvider<OrderNotifier, List<Order>>(
  OrderNotifier.new,
);

class OrderNotifier extends Notifier<List<Order>> {
  @override
  List<Order> build() {
    return [];
  }

  void addOrder(Order order) {
    state = [...state, order];
  }

  void removeOrder(String orderId) {
    state = state.where((order) => order.id != orderId).toList();
  }

  void clearOrders() {
    state = [];
  }
}