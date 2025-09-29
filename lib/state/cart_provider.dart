import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_client.dart';
import '../pages/cart_page.dart' show CartItemModel; // reuse model

class CartState {
  final bool loading;
  final String? error;
  final List<CartItemModel> items;

  const CartState({this.loading = false, this.error, this.items = const []});

  CartState copyWith({bool? loading, String? error, List<CartItemModel>? items}) {
    return CartState(
      loading: loading ?? this.loading,
      error: error,
      items: items ?? this.items,
    );
  }
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  Future<void> loadIfNeeded() async {
    if (state.items.isNotEmpty) return;
    await reload();
  }

  Future<void> reload() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final res = await ApiClient().get('/carts');
      final data = res.data;
      List<CartItemModel> parsed = [];
      if (data is List) {
        parsed = data
            .whereType<Map<String, dynamic>>()
            .map(CartItemModel.fromJson)
            .toList();
      } else if (data is Map && data['items'] is List) {
        parsed = (data['items'] as List)
            .whereType<Map<String, dynamic>>()
            .map(CartItemModel.fromJson)
            .toList();
      }
      state = state.copyWith(loading: false, items: parsed);
    } catch (e) {
      state = state.copyWith(loading: false, error: 'Failed to load cart');
    }
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});



