import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/cloudinary.dart';
import '../components/app_scaffold.dart';
import '../state/orders_provider.dart';

class OrdersPage extends ConsumerStatefulWidget {
  const OrdersPage({super.key});

  @override
  ConsumerState<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends ConsumerState<OrdersPage> {
  // state comes from provider; keep only view-specific selections below
  List<dynamic> _orders = [];
  List<dynamic> _filteredOrders = [];
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(ordersProvider.notifier).loadIfNeeded().then((_) => _hydrateFromState()));
  }

  Future<void> _loadOrders() async {
    await ref.read(ordersProvider.notifier).reload();
    _hydrateFromState();
  }

  void _hydrateFromState() {
    final s = ref.read(ordersProvider);
    _orders = s.orders;
    _applyFilter();
  }

  void _applyFilter() {
    if (_selectedStatus == 'all') {
      _filteredOrders = List.of(_orders);
    } else {
      final sel = _selectedStatus;
      _filteredOrders = _orders.where((order) {
        final status = order['status'];
        final name = (status is Map ? status['name'] : null)?.toString();
        final idFromStatus = (status is Map ? status['id'] : null)?.toString();
        final id = order['status_id']?.toString();
        if (idFromStatus == sel) return true;
        if (id == sel) return true;
        if (name != null && name.toLowerCase() == sel.toLowerCase()) return true;
        return false;
      }).toList();
    }
    if (mounted) setState(() {});
  }

  String _statusColorClasses(String? statusRaw) {
    final statusLower = (statusRaw ?? '').toLowerCase().trim();
    if (statusLower.contains('pending') || statusLower.contains('processing') || statusLower == 'awaiting') {
      return 'yellow';
    }
    if (statusLower.contains('ship') || statusLower.contains('deliver') || statusLower == 'completed' || statusLower == 'done') {
      return 'green';
    }
    if (statusLower.contains('cancel') || statusLower.contains('fail') || statusLower.contains('reject') || statusLower.contains('return')) {
      return 'red';
    }
    return 'gray';
  }

  Color _chipBg(String k) {
    switch (k) {
      case 'yellow':
        return const Color(0xFFFFF9C4);
      case 'green':
        return const Color(0xFFC8E6C9);
      case 'red':
        return const Color(0xFFFFCDD2);
      default:
        return const Color(0xFFE0E0E0);
    }
  }

  Color _chipFg(String k) {
    switch (k) {
      case 'yellow':
        return const Color(0xFFF57F17);
      case 'green':
        return const Color(0xFF1B5E20);
      case 'red':
        return const Color(0xFFB71C1C);
      default:
        return const Color(0xFF424242);
    }
  }

  String _formatDate(String? dateIso) {
    if (dateIso == null || dateIso.isEmpty) return '';
    final dt = DateTime.tryParse(dateIso);
    if (dt == null) return '';
    return '${dt.day.toString().padLeft(2, '0')} ${_month(dt.month)} ${dt.year}';
  }

  String _month(int m) {
    const names = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return names[(m - 1).clamp(0, 11)];
    }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(ordersProvider);
    return AppScaffold(
      isHomeHeader: false,
      currentIndex: 2,
      body: Container(
        color: const Color(0xFFF7F7F7),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: s.loading
              ? const Center(
                  child: SizedBox(
                    height: 32,
                    width: 32,
                    child: CircularProgressIndicator(),
                  ),
                )
              : s.error != null
                  ? _ErrorBox(message: s.error!, onRetry: _loadOrders)
                  : s.orders.isEmpty
                      ? _EmptyOrders(onExplore: () => Navigator.pushNamed(context, '/product'))
                      : Column(
                          children: [
                            // Filter row
                            if (s.statuses.isNotEmpty)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    FilterChip(
                                      label: const Text('All Orders'),
                                      selected: _selectedStatus == 'all',
                                      onSelected: (_) {
                                        setState(() => _selectedStatus = 'all');
                                        _applyFilter();
                                      },
                                    ),
                                    ...s.statuses.map((status) {
                                      return FilterChip(
                                        label: Text(status[0].toUpperCase() + status.substring(1).toLowerCase()),
                                        selected: _selectedStatus.toLowerCase() == status.toLowerCase(),
                                        onSelected: (_) {
                                          setState(() => _selectedStatus = status);
                                          _applyFilter();
                                        },
                                      );
                                    }).toList(),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: RefreshIndicator(
                                onRefresh: _loadOrders,
                                child: ListView.separated(
                                  itemCount: _filteredOrders.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final order = _filteredOrders[index] as Map<String, dynamic>;
                                    final statusName = (order['status'] is Map)
                                        ? (order['status']['name']?.toString() ?? order['status']['id']?.toString() ?? order['status_id']?.toString() ?? 'Unknown')
                                        : (order['status_id']?.toString() ?? 'Unknown');
                                    final colorKey = _statusColorClasses(statusName);
                                    final totalRaw = order['total'];
                                    double? total;
                                    if (totalRaw is num) total = totalRaw.toDouble();
                                    if (totalRaw is String) total = double.tryParse(totalRaw);

                                    return Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text('Order #${order['id']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                                    if (order['created_at'] != null)
                                                      Text('Placed on ${_formatDate(order['created_at']?.toString())}', style: const TextStyle(color: Colors.grey)),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: _chipBg(colorKey),
                                                        borderRadius: BorderRadius.circular(999),
                                                      ),
                                                      child: Text(
                                                        statusName,
                                                        style: TextStyle(fontSize: 12, color: _chipFg(colorKey)),
                                                      ),
                                                    ),
                                                    if (total != null) ...[
                                                      const SizedBox(width: 8),
                                                      Text('₹${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                                                    ],
                                                  ],
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Column(
                                              children: List<Widget>.from(((order['cart']?['items']) ?? [])
                                                  .asMap()
                                                  .entries
                                                  .map((entry) {
                                                final item = entry.value as Map<String, dynamic>;
                                                final product = (item['product'] ?? {}) as Map<String, dynamic>;
                                                final imagePublicId = product['image_public_id']?.toString();
                                                final imageUrl = imagePublicId != null
                                                    ? CloudinaryUtils.getCloudinaryUrl(imagePublicId)
                                                    : null;
                                                final priceRaw = item['price'];
                                                double? price;
                                                if (priceRaw is num) price = priceRaw.toDouble();
                                                if (priceRaw is String) price = double.tryParse(priceRaw);
                                                final quantity = (item['quantity'] is num) ? (item['quantity'] as num).toInt() : int.tryParse(item['quantity']?.toString() ?? '');
                                                final lineTotal = (price != null && quantity != null) ? price * quantity : null;

                                                return Container(
                                                  margin: const EdgeInsets.only(bottom: 8),
                                                  padding: const EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFF5F5F5),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Container(
                                                        height: 56,
                                                        width: 56,
                                                        decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius: BorderRadius.circular(8),
                                                          border: Border.all(color: const Color(0xFFE0E0E0)),
                                                        ),
                                                        clipBehavior: Clip.antiAlias,
                                                        child: imageUrl != null
                                                            ? Image.network(imageUrl, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported))
                                                            : const Icon(Icons.image_not_supported),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text((product['name'] ?? 'Item').toString(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                                                            if (product['description'] != null)
                                                              Padding(
                                                                padding: const EdgeInsets.only(top: 2),
                                                                child: Text((product['description']).toString(), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.end,
                                                        children: [
                                                          const Text('Quantity', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                                          Text('${quantity ?? '-'}'),
                                                        ],
                                                      ),
                                                      const SizedBox(width: 12),
                                                      if (price != null)
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.end,
                                                          children: [
                                                            const Text('Price', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                                            Text('₹${price.toStringAsFixed(2)}'),
                                                          ],
                                                        ),
                                                      const SizedBox(width: 12),
                                                      if (lineTotal != null)
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.end,
                                                          children: [
                                                            const Text('Total', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                                            Text('₹${lineTotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF267E82))),
                                                          ],
                                                        ),
                                                    ],
                                                  ),
                                                );
                                              })),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                OutlinedButton(
                                                  onPressed: () {},
                                                  child: const Text('View Details'),
                                                ),
                                                const SizedBox(width: 8),
                                                OutlinedButton(
                                                  onPressed: () {},
                                                  child: const Text('Track Order'),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
        ),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBox({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        border: Border.all(color: const Color(0xFFEF9A9A)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFD32F2F), size: 32),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFD32F2F))),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Try Again')),
        ],
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  final VoidCallback onExplore;
  const _EmptyOrders({required this.onExplore});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 12),
          const Text('No Orders Yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          const Text('You haven\'t placed any orders yet. Start shopping to see your order history here.', textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onExplore, child: const Text('Start Shopping')),
        ],
      ),
    );
  }
}


