class Product {
  final int id;
  final String name;
  final String description;
  final String imagePublicId;
  final int totalStock;
  final bool isInStock;
  final int availableLots;
  final int categoryId;
  final String categoryName;
  final int industryId;
  final String industryName;
  final int materialId;
  final String materialName;
  final bool isFerrous;
  final List<dynamic> lots;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePublicId,
    required this.totalStock,
    required this.isInStock,
    required this.availableLots,
    required this.categoryId,
    required this.categoryName,
    required this.industryId,
    required this.industryName,
    required this.materialId,
    required this.materialName,
    required this.isFerrous,
    required this.lots,
  });

  factory Product.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Product._empty();
    }

    // Safely extract nested objects
    final category = _safeExtractMap(json['category']);
    final industry = _safeExtractMap(json['industry']);
    final material = _safeExtractMap(json['material']);
    
    return Product(
      id: _safeExtractInt(json['id']) ?? 0,
      name: _safeExtractString(json['name']) ?? 'Unknown Product',
      description: _safeExtractString(json['description']) ?? '',
      imagePublicId: _safeExtractString(json['image_public_id']) ?? '',
      totalStock: _safeExtractInt(json['totalStock']) ?? 0,
      isInStock: _safeExtractBool(json['isInStock']) ?? false,
      availableLots: _safeExtractInt(json['availableLots']) ?? 0,
      categoryId: _safeExtractInt(json['category_id']) ?? 0,
      categoryName: _safeExtractString(category?['name']) ?? 'Unknown Category',
      industryId: _safeExtractInt(json['industry_id']) ?? 0,
      industryName: _safeExtractString(industry?['name']) ?? 'Unknown Industry',
      materialId: _safeExtractInt(json['material_id']) ?? 0,
      materialName: _safeExtractString(material?['name']) ?? 'Unknown Material',
      isFerrous: _safeExtractBool(material?['ferros']) ?? false,
      lots: _safeExtractList(json['lots']) ?? [],
    );
  }

  // Empty constructor for error cases
  Product._empty()
      : id = 0,
        name = 'Unknown Product',
        description = '',
        imagePublicId = '',
        totalStock = 0,
        isInStock = false,
        availableLots = 0,
        categoryId = 0,
        categoryName = 'Unknown Category',
        industryId = 0,
        industryName = 'Unknown Industry',
        materialId = 0,
        materialName = 'Unknown Material',
        isFerrous = false,
        lots = [];

  // Helper methods for safe extraction
  static String? _safeExtractString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value.trim();
    return value.toString().trim();
  }

  static int? _safeExtractInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  static bool? _safeExtractBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true';
    }
    return null;
  }

  static Map<String, dynamic>? _safeExtractMap(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  static List<dynamic>? _safeExtractList(dynamic value) {
    if (value == null) return null;
    if (value is List) return value;
    return null;
  }
}