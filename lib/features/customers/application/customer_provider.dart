import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yarpay/data/services/supabase_service.dart';
import 'package:yarpay/features/customers/domain/customer.dart';
import 'package:yarpay/features/restaurant/application/restaurant_provider.dart';

class CustomerNotifier extends Notifier<List<Customer>> {
  @override
  List<Customer> build() {
    final restaurantId = ref.watch(restaurantIdProvider);

    if (restaurantId != null) {
      _loadCustomers();
    }

    return [];
  }

  Future<void> _loadCustomers() async {
    try {
      final response = await SupabaseService.client.rpc('get_customers');
      final list = (response as List<dynamic>? ?? []).map((json) {
        return Customer.fromJson(json as Map<String, dynamic>);
      }).toList();
      state = list;
    } catch (e) {
      state = [];
    }
  }

  Future<void> refresh() async {
    await _loadCustomers();
  }

  Future<Customer?> addCustomer({
    required String name,
    String phone = '',
    String email = '',
    String address = '',
  }) async {
    try {
      final response = await SupabaseService.client.rpc('add_customer', params: {
        'p_name': name,
        'p_phone': phone,
        'p_email': email,
        'p_address': address,
      });

      await refresh();
      return Customer.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateCustomer({
    required String id,
    required String name,
    String phone = '',
    String email = '',
    String address = '',
  }) async {
    try {
      await SupabaseService.client.rpc('update_customer', params: {
        'p_id': id,
        'p_name': name,
        'p_phone': phone,
        'p_email': email,
        'p_address': address,
      });

      await refresh();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteCustomer(String id) async {
    try {
      await SupabaseService.client.rpc('delete_customer', params: {
        'p_id': id,
      });

      await refresh();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final customerProvider =
    NotifierProvider<CustomerNotifier, List<Customer>>(CustomerNotifier.new);
