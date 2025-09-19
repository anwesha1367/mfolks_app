class Product {
  final int id;
  final String name;
  final String description;
  final String imagePublicId;
  final int totalStock;
  final bool isInStock;
  final int availableLots;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePublicId,
    required this.totalStock,
    required this.isInStock,
    required this.availableLots,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imagePublicId: json['image_public_id'] as String? ?? '',
      totalStock: (json['totalStock'] as num?)?.toInt() ?? 0,
      isInStock: json['isInStock'] as bool? ?? (json['availableLots'] != null ? (json['availableLots'] as num) > 0 : false),
      availableLots: (json['availableLots'] as num?)?.toInt() ?? 0,
    );
  }
}
