import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/app_scaffold.dart';
import '../services/api_client.dart';
import '../utils/cloudinary.dart';
import '../state/cart_provider.dart';

class CartItemModel {
  final int id;
  final int quantity;
  final Map<String, dynamic> product;
  CartItemModel({
    required this.id,
    required this.quantity,
    required this.product,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as int,
      quantity: (json['quantity'] as num).toInt(),
      product: Map<String, dynamic>.from(json['product'] as Map),
    );
  }
}

class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  bool loading = true;
  String? error;
  List<CartItemModel> items = [];
  final Set<int> updating = {};
  final Set<int> removing = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(cartProvider.notifier).loadIfNeeded());
  }

  // Loading handled via cartProvider

  Future<void> _updateQty(int itemId, int quantity) async {
    if (quantity < 1) return;
    setState(() => updating.add(itemId));
    try {
      await ApiClient().post(
        '/carts/items/$itemId',
        data: {'quantity': quantity},
      );
      if (mounted) ref.read(cartProvider.notifier).reload();
    } catch (_) {
    } finally {
      setState(() => updating.remove(itemId));
    }
  }

  Future<void> _removeItem(int itemId) async {
    setState(() => removing.add(itemId));
    try {
      await ApiClient().post('/carts/items/$itemId/delete');
      if (mounted) ref.read(cartProvider.notifier).reload();
    } catch (_) {
    } finally {
      setState(() => removing.remove(itemId));
    }
  }

  double _getCartTotal(List<CartItemModel> items) {
    double total = 0;
    for (final item in items) {
      final price = (item.product['price'] as num?)?.toDouble() ?? 0;
      total += price * item.quantity;
    }
    return total;
  }

  // Totals computed via helper using provider items

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final isEmpty = cartState.items.isEmpty;
    return AppScaffold(
      isHomeHeader: false,
      currentIndex: 2,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: cartState.loading
            ? const Center(child: CircularProgressIndicator())
            : cartState.error != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(cartState.error!),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () => ref.read(cartProvider.notifier).reload(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : isEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Your cart is empty'),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, '/home'),
                    child: const Text('Start Shopping'),
                  ),
                ],
              )
              : Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      itemCount: cartState.items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final item = cartState.items[i];
                        final p = item.product;
                        final name = (p['name'] as String?) ?? 'Product';
                        final desc = (p['description'] as String?) ?? '';
                        final publicId =
                            (p['image_public_id'] as String?) ?? '';
                        final price = (p['price'] as num?)?.toDouble();
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    publicId.isNotEmpty
                                        ? CloudinaryUtils.getCloudinaryUrl(
                                            publicId,
                                          )
                                        : 'https://via.placeholder.com/80x80.png?text=Product',
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        desc,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          IconButton(
                                            onPressed:
                                                (item.quantity > 1 &&
                                                    !updating.contains(item.id))
                                                ? () => _updateQty(
                                                    item.id,
                                                    item.quantity - 1,
                                                  )
                                                : null,
                                            icon: const Icon(
                                              Icons.remove_circle_outline,
                                            ),
                                          ),
                                          Text(
                                            updating.contains(item.id)
                                                ? 'Updating...'
                                                : item.quantity.toString(),
                                          ),
                                          IconButton(
                                            onPressed:
                                                !updating.contains(item.id)
                                                ? () => _updateQty(
                                                    item.id,
                                                    item.quantity + 1,
                                                  )
                                                : null,
                                            icon: const Icon(
                                              Icons.add_circle_outline,
                                            ),
                                          ),
                                          const Spacer(),
                                          price != null
                                              ? Text(
                                                  '₹${price.toStringAsFixed(2)}',
                                                )
                                              : const SizedBox(),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: removing.contains(item.id)
                                      ? null
                                      : () => _removeItem(item.id),
                                  icon: removing.contains(item.id)
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.delete_outline),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Subtotal'),
                            Text('₹${_getCartTotal(cartState.items).toStringAsFixed(2)}'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Tax (8%)'),
                            Text('₹${(_getCartTotal(cartState.items) * 0.08).toStringAsFixed(2)}'),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('₹${(_getCartTotal(cartState.items) * 1.08).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () async {
                                  await ApiClient().post('/carts/clear');
                                  if (mounted) ref.read(cartProvider.notifier).reload();
                                },
                                child: const Text('Clear Cart'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {},
                                child: const Text('Checkout'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
