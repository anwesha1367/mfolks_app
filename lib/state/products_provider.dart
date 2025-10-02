import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../services/api_client.dart';

class ProductsState {
  final List<Product> products;
  final bool loaded;
  final DateTime? lastFetchedAt;

  const ProductsState({
    this.products = const [],
    this.loaded = false,
    this.lastFetchedAt,
  });

  ProductsState copyWith({
    List<Product>? products,
    bool? loaded,
    DateTime? lastFetchedAt,
  }) {
    return ProductsState(
      products: products ?? this.products,
      loaded: loaded ?? this.loaded,
      lastFetchedAt: lastFetchedAt ?? this.lastFetchedAt,
    );
  }
}

class ProductsNotifier extends StateNotifier<ProductsState> {
  ProductsNotifier() : super(const ProductsState());

  Future<void> loadIfNeeded() async {
    if (state.loaded && state.products.isNotEmpty) return;
    try {
      final response = await ApiClient().get('/products');
      final data = response.data;
      
      // Handle the correct API response structure: { data: [...] }
      List<dynamic> productsData = [];
      if (data is Map && data['data'] is List) {
        productsData = data['data'] as List<dynamic>;
      } else if (data is List) {
        productsData = data;
      }
      
      final list = productsData
          .whereType<Map<String, dynamic>>()
          .map((e) => Product.fromJson(e))
          .toList();
          
      state = state.copyWith(
        products: list,
        loaded: true,
        lastFetchedAt: DateTime.now(),
      );
    } catch (e) {
      print('Error loading products: $e');
      // keep state as is on failure
      state = state.copyWith(loaded: true, lastFetchedAt: DateTime.now());
    }
  }
}

final productsProvider =
    StateNotifierProvider<ProductsNotifier, ProductsState>((ref) {
  return ProductsNotifier();
});



