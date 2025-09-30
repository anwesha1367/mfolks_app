import 'package:flutter/material.dart';
import '../models/product.dart';
import '../utils/cloudinary.dart';
import '../services/api_client.dart';
import '../widget/custom_header.dart';

class ProductDetailsPage extends StatefulWidget {
  const ProductDetailsPage({super.key});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  Product? product;
  bool loading = true;
  bool adding = false;
  int quantity = 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Product) {
      product = args;
      loading = false;
      setState(() {});
    } else if (args is int) {
      _fetchProduct(args);
    } else {
      loading = false;
      setState(() {});
    }
  }

  Future<void> _fetchProduct(int id) async {
    setState(() {
      loading = true;
    });
    try {
      final res = await ApiClient().get<Map<String, dynamic>>('/products/$id');
      product = Product.fromJson(res.data ?? {});
    } catch (_) {
      product = null;
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Future<void> _addToCart() async {
    if (product == null || adding) return;
    setState(() {
      adding = true;
    });
    try {
      await ApiClient().post(
        '/carts/items',
        data: {'product_id': product!.id, 'quantity': quantity},
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Added to cart')));
      Navigator.pushNamed(context, '/cart');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add to cart. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          adding = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (product == null) {
      return Scaffold(
        appBar: const CustomHeader(isHome: false),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Product not found'),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/home'),
                child: const Text('Back to Products'),
              ),
            ],
          ),
        ),
      );
    }

    // Determine display name and asset override regardless of cloud image
    final String originalName = product!.name;
    String displayName = originalName;
    String fallbackAsset = 'assets/mfolks-logo.png';
    bool overrideAsset = false;
    final String lname = originalName.toLowerCase();

    // Metal rod → Polymer
    if ((lname.contains('metal') && lname.contains('rod')) ||
        lname.contains('metal rod')) {
      displayName = 'Polymer';
      fallbackAsset = 'assets/polymers.png';
      overrideAsset = true;
    }
    // Copper/Cooper wire → copper.png
    else if ((lname.contains('copper') || lname.contains('cooper')) &&
        lname.contains('wire')) {
      fallbackAsset = 'assets/copper.png';
      overrideAsset = true;
    }
    // Aluminium/Aluminum sheet or wire → aluminium.jpg
    else if ((lname.contains('aluminium') || lname.contains('aluminum')) &&
        (lname.contains('sheet') || lname.contains('wire'))) {
      fallbackAsset = 'assets/aluminium.jpg';
      overrideAsset = true;
    }

    return Scaffold(
      appBar: const CustomHeader(isHome: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: overrideAsset
                  ? Image.asset(
                      fallbackAsset,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : (product!.imagePublicId.isNotEmpty
                        ? Image.network(
                            CloudinaryUtils.getCloudinaryUrl(
                              product!.imagePublicId,
                            ),
                            height: 220,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            fallbackAsset,
                            height: 220,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )),
            ),
            const SizedBox(height: 16),
            Text(
              displayName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00695C),
              ),
            ),
            const SizedBox(height: 8),
            Text(product!.description),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  product!.isInStock ? Icons.check_circle : Icons.error_outline,
                  color: product!.isInStock ? Colors.green : Colors.red,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(product!.isInStock ? 'In stock' : 'Out of stock'),
                const SizedBox(width: 16),
                Text('Total: ${product!.totalStock}'),
                const SizedBox(width: 16),
                Text('Lots: ${product!.availableLots}'),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Quantity',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: quantity > 1
                                ? () => setState(() => quantity -= 1)
                                : null,
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text(
                            quantity.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            onPressed:
                                product!.isInStock &&
                                    quantity < product!.totalStock
                                ? () => setState(() => quantity += 1)
                                : null,
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: product!.isInStock
                          ? (adding ? null : _addToCart)
                          : null,
                      child: adding
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Add to Cart'),
                    ),
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
