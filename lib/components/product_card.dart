import 'package:flutter/material.dart';
import '../models/product.dart';
import '../utils/cloudinary.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onView;
  final VoidCallback? onAddToCart;
  final bool isAdding;

  const ProductCard({
    super.key,
    required this.product,
    required this.onView,
    this.onAddToCart,
    this.isAdding = false,
  });

  @override
  Widget build(BuildContext context) {
    // Determine display name and override asset based on product name
    final String originalName = product.name;
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
    // Aluminium/Aluminum sheet or wire → aluminium.png
    else if ((lname.contains('aluminium') || lname.contains('aluminum')) &&
        (lname.contains('sheet') || lname.contains('wire'))) {
      fallbackAsset = 'assets/aluminium.jpg';
      overrideAsset = true;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2F1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: overrideAsset
                    ? Image.asset(fallbackAsset, fit: BoxFit.cover)
                    : (product.imagePublicId.isNotEmpty
                          ? Image.network(
                              CloudinaryUtils.getCloudinaryUrl(
                                product.imagePublicId,
                              ),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.category,
                                  color: Color(0xFF00695C),
                                  size: 40,
                                );
                              },
                            )
                          : Image.asset(fallbackAsset, fit: BoxFit.cover)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF00695C),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        product.isInStock
                            ? Icons.check_circle
                            : Icons.error_outline,
                        color: product.isInStock ? Colors.green : Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        product.isInStock ? 'In stock' : 'Out of stock',
                        style: TextStyle(
                          color: product.isInStock ? Colors.green : Colors.red,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Row(
                          children: [
                            Text(
                              'Total: ${product.totalStock}',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Lots: ${product.availableLots}',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: onView, child: const Text('View')),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: isAdding ? null : onAddToCart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00897B),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: isAdding
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Add to Cart'),
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
