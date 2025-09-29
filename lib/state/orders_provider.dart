import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/orders_service.dart';

class OrdersState {
  final bool loading;
  final String? error;
  final List<Map<String, dynamic>> orders;
  final List<String> statuses;

  const OrdersState({
    this.loading = false,
    this.error,
    this.orders = const [],
    this.statuses = const [],
  });

  OrdersState copyWith({
    bool? loading,
    String? error,
    List<Map<String, dynamic>>? orders,
    List<String>? statuses,
  }) {
    return OrdersState(
      loading: loading ?? this.loading,
      error: error,
      orders: orders ?? this.orders,
      statuses: statuses ?? this.statuses,
    );
  }
}

class OrdersNotifier extends StateNotifier<OrdersState> {
  OrdersNotifier() : super(const OrdersState());

  Future<void> loadIfNeeded() async {
    if (state.orders.isNotEmpty) return;
    await reload();
  }

  Future<void> reload() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final data = await OrdersService.instance.fetchOrders();
      final statuses = OrdersService.instance.extractStatuses(data);
      state = state.copyWith(loading: false, orders: data, statuses: statuses);
    } catch (e) {
      state = state.copyWith(loading: false, error: 'Failed to load orders. Please login.');
    }
  }
}

final ordersProvider = StateNotifierProvider<OrdersNotifier, OrdersState>((ref) {
  return OrdersNotifier();
});



