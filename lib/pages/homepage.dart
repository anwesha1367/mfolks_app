import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../utils/cloudinary.dart';
import '../services/api_client.dart';
import '../widget/custom_footer.dart';
import '../widget/custom_drawer.dart';
import '../state/user_notifier.dart';
import '../models/user.dart';
import '../components/product_card.dart';
import '../components/app_header.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 2; // Home selected
  late List<Product> products;
  int? _addingId;

  @override
  void initState() {
    super.initState();
    products = [];
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final res = await ApiClient().get<List<dynamic>>('/products');
      final list = (res.data ?? [])
          .whereType<Map<String, dynamic>>()
          .map((e) => Product.fromJson(e))
          .toList();
      if (mounted) {
        setState(() {
          products = list;
        });
      }
    } catch (_) {
      // Keep empty list on error; could show a snackbar
    }
  }

  Future<void> _addToCart(Product product) async {
    if (_addingId != null) return;
    setState(() {
      _addingId = product.id;
    });
    try {
      await ApiClient().post('/carts/items', data: {
        'product_id': product.id,
        'quantity': 1,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added to cart')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add to cart. Please login.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _addingId = null;
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushNamed(context, "/about");
        break;
      case 1:
        Navigator.pushNamed(context, "/quote");
        break;
      case 2:
        Navigator.pushNamed(context, "/home");
        break;
      case 3:
        Navigator.pushNamed(context, "/analytics");
        break;
      case 4:
        Navigator.pushNamed(context, "/calculator");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppUser? user = ref.watch(userProvider);
    final String displayName = (user?.fullname?.trim().isNotEmpty == true)
        ? user!.fullname!.trim()
        : 'MFolks Partner';
    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      drawer: const CustomDrawer(),
      appBar: const AppHeader(),
      body: Column(
        children: [
          // Welcome Header
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00695C), Color(0xFF00897B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.waving_hand, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome${user?.fullname != null ? ', ${user!.fullname}' : ''}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "Explore the products",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Products List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductCard(
                  product: product,
                  onView: () => Navigator.pushNamed(context, '/product', arguments: product),
                  onAddToCart: () => _addToCart(product),
                  isAdding: _addingId == product.id,
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomFooter(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
