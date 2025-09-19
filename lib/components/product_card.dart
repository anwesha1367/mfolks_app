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
                child: Image.network(
                  product.imagePublicId.isNotEmpty
                      ? CloudinaryUtils.getCloudinaryUrl(product.imagePublicId)
                      : 'https://via.placeholder.com/100x80.png?text=Product',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.category,
                      color: Color(0xFF00695C),
                      size: 40,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
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
                        product.isInStock ? Icons.check_circle : Icons.error_outline,
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
                      TextButton(
                        onPressed: onView,
                        child: const Text('View'),
                      ),
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


