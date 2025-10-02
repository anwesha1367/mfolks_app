import 'package:dio/dio.dart';
import 'api_client.dart';

class SearchService {
  SearchService._();
  static final SearchService instance = SearchService._();

  /// Search products with query string
  /// Equivalent to: GET /products?search={query}
  Future<List<Map<String, dynamic>>> searchProducts({
    required String query,
    int? limit,
    int? offset,
    String? category,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'search': query,
        if (limit != null) 'limit': limit,
        if (offset != null) 'offset': offset,
        if (category != null && category.isNotEmpty) 'category': category,
        if (sortBy != null && sortBy.isNotEmpty) 'sort_by': sortBy,
        if (sortOrder != null && sortOrder.isNotEmpty) 'sort_order': sortOrder,
      };

      final Response response = await ApiClient().get('/products', query: queryParams);
      final data = response.data;
      
      if (data is Map && data['data'] is List) {
        return (data['data'] as List).map((e) {
          if (e is Map) {
            return Map<String, dynamic>.from(e);
          }
          return <String, dynamic>{};
        }).toList();
      }
      
      if (data is List) {
        return data.map((e) {
          if (e is Map) {
            return Map<String, dynamic>.from(e);
          }
          return <String, dynamic>{};
        }).toList();
      }
      
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: 'Invalid search results format',
        type: DioExceptionType.badResponse,
      );
    } catch (e) {
      print('SearchService.searchProducts error: $e');
      rethrow;
    }
  }

  /// Get search suggestions/autocomplete
  /// Equivalent to: GET /search/suggestions?q={query}
  Future<List<String>> getSearchSuggestions({
    required String query,
    int limit = 5,
  }) async {
    try {
      final Response response = await ApiClient().get('/search/suggestions', query: {
        'q': query,
        'limit': limit,
      });
      
      final data = response.data;
      if (data is List) {
        return data.map((e) => e.toString()).toList();
      }
      
      if (data is Map && data['suggestions'] is List) {
        return (data['suggestions'] as List).map((e) => e.toString()).toList();
      }
      
      return [];
    } catch (e) {
      print('SearchService.getSearchSuggestions error: $e');
      return [];
    }
  }

  /// Get popular search terms
  /// Equivalent to: GET /search/popular
  Future<List<String>> getPopularSearches({int limit = 10}) async {
    try {
      final Response response = await ApiClient().get('/search/popular', query: {
        'limit': limit,
      });
      
      final data = response.data;
      if (data is List) {
        return data.map((e) => e.toString()).toList();
      }
      
      if (data is Map && data['popular'] is List) {
        return (data['popular'] as List).map((e) => e.toString()).toList();
      }
      
      return [];
    } catch (e) {
      print('SearchService.getPopularSearches error: $e');
      return [];
    }
  }

  /// Get search categories/filters
  /// Equivalent to: GET /search/categories
  Future<List<Map<String, dynamic>>> getSearchCategories() async {
    try {
      final Response response = await ApiClient().get('/search/categories');
      final data = response.data;
      
      if (data is List) {
        return data.map((e) {
          if (e is Map) {
            return Map<String, dynamic>.from(e);
          }
          return <String, dynamic>{};
        }).toList();
      }
      
      if (data is Map && data['categories'] is List) {
        return (data['categories'] as List).map((e) {
          if (e is Map) {
            return Map<String, dynamic>.from(e);
          }
          return <String, dynamic>{};
        }).toList();
      }
      
      return [];
    } catch (e) {
      print('SearchService.getSearchCategories error: $e');
      return [];
    }
  }

  /// Filter search results by category
  List<Map<String, dynamic>> filterByCategory(
    List<Map<String, dynamic>> results,
    String category,
  ) {
    if (category.isEmpty || category == 'all') return List.of(results);
    
    return results.where((product) {
      final productCategory = product['category']?.toString().toLowerCase();
      return productCategory == category.toLowerCase();
    }).toList();
  }

  /// Sort search results
  List<Map<String, dynamic>> sortResults(
    List<Map<String, dynamic>> results,
    String sortBy,
    String sortOrder,
  ) {
    if (sortBy.isEmpty) return List.of(results);
    
    final isAscending = sortOrder.toLowerCase() == 'asc';
    
    switch (sortBy.toLowerCase()) {
      case 'name':
        results.sort((a, b) {
          final nameA = (a['name'] ?? '').toString().toLowerCase();
          final nameB = (b['name'] ?? '').toString().toLowerCase();
          return isAscending ? nameA.compareTo(nameB) : nameB.compareTo(nameA);
        });
        break;
        
      case 'price':
        results.sort((a, b) {
          final priceA = (a['price'] ?? 0).toDouble();
          final priceB = (b['price'] ?? 0).toDouble();
          return isAscending ? priceA.compareTo(priceB) : priceB.compareTo(priceA);
        });
        break;
        
      case 'category':
        results.sort((a, b) {
          final categoryA = (a['category'] ?? '').toString().toLowerCase();
          final categoryB = (b['category'] ?? '').toString().toLowerCase();
          return isAscending ? categoryA.compareTo(categoryB) : categoryB.compareTo(categoryA);
        });
        break;
        
      case 'relevance':
      default:
        // Keep original order for relevance
        break;
    }
    
    return results;
  }

  /// Extract unique categories from search results
  List<String> extractCategories(List<Map<String, dynamic>> results) {
    final categories = results.map((product) {
      return (product['category'] ?? 'Unknown').toString();
    }).toSet();
    
    return categories.toList()..sort();
  }

  /// Get price range from search results
  Map<String, double> getPriceRange(List<Map<String, dynamic>> results) {
    if (results.isEmpty) return {'min': 0.0, 'max': 0.0};
    
    final prices = results.map((product) {
      return (product['price'] ?? 0).toDouble();
    }).toList();
    
    prices.sort();
    
    return {
      'min': prices.first,
      'max': prices.last,
    };
  }

  /// Highlight search terms in text
  String highlightSearchTerms(String text, String query) {
    if (query.isEmpty) return text;
    
    final queryTerms = query.toLowerCase().split(' ').where((term) => term.isNotEmpty).toList();
    if (queryTerms.isEmpty) return text;
    
    String highlightedText = text;
    for (final term in queryTerms) {
      final regex = RegExp(term, caseSensitive: false);
      highlightedText = highlightedText.replaceAll(regex, '<mark>$term</mark>');
    }
    
    return highlightedText;
  }

  /// Check if search query is valid
  bool isValidSearchQuery(String query) {
    return query.trim().length >= 2;
  }

  /// Clean and normalize search query
  String normalizeQuery(String query) {
    return query.trim().toLowerCase();
  }
}
