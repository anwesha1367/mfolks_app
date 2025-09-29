import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../components/product_card.dart';
import '../models/product.dart';
import '../services/api_client.dart';
import '../state/products_provider.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _searchTimer;
  List<Product> _filteredProducts = [];
  String _selectedCategory = 'all';
  String _selectedIndustry = 'all';
  String _selectedMaterial = 'all';
  String _sortBy = 'relevance';
  int? _addingId;

  @override
  void initState() {
    super.initState();
    // Load products using the same provider as home page
    Future.microtask(() => ref.read(productsProvider.notifier).loadIfNeeded());
    
    // Set up search debouncing like temp.dart
    _searchController.addListener(() {
      if (_searchTimer != null) {
        _searchTimer!.cancel();
      }
      
      if (_searchController.text.trim().length > 1) {
        _searchTimer = Timer(const Duration(milliseconds: 300), () {
          _performSearch();
        });
      } else {
        _applyFilters();
      }
    });
    
    // Handle navigation arguments for category filter
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['category'] != null) {
        setState(() {
          _selectedMaterial = args['category'];
        });
        _applyFilters();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      _applyFilters();
      return;
    }

    try {
      // Make API call like in temp.dart: `/products?search=${encodeURIComponent(searchQuery.trim())}`
      final response = await ApiClient().get('/products', query: {
        'search': query,
      });
      
      final data = response.data;
      List<dynamic> productsData = [];
      
      // Handle the API response structure
      if (data is Map && data['data'] is List) {
        productsData = data['data'] as List<dynamic>;
      } else if (data is List) {
        productsData = data;
      }
      
      // Convert to Product objects
      final searchResults = productsData
          .whereType<Map<String, dynamic>>()
          .map((e) => Product.fromJson(e))
          .toList();
      
      // Apply additional filters to search results
      List<Product> filtered = List.from(searchResults);
      
      // Apply material filter (Ferrous/Non-Ferrous)
      if (_selectedMaterial == 'Ferrous') {
        filtered = filtered.where((product) => product.isFerrous).toList();
      } else if (_selectedMaterial == 'Non-Ferrous') {
        filtered = filtered.where((product) => !product.isFerrous).toList();
      }
      
      // Apply category filter
      if (_selectedCategory != 'all') {
        filtered = filtered.where((product) => product.categoryName == _selectedCategory).toList();
      }
      
      // Apply industry filter
      if (_selectedIndustry != 'all') {
        filtered = filtered.where((product) => product.industryName == _selectedIndustry).toList();
      }
      
      // Apply sorting
      switch (_sortBy) {
        case 'name_asc':
          filtered.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'name_desc':
          filtered.sort((a, b) => b.name.compareTo(a.name));
          break;
        case 'stock_asc':
          filtered.sort((a, b) => a.totalStock.compareTo(b.totalStock));
          break;
        case 'stock_desc':
          filtered.sort((a, b) => b.totalStock.compareTo(a.totalStock));
          break;
        default: // relevance - keep original order
          break;
      }
      
      setState(() {
        _filteredProducts = filtered;
      });
    } catch (error) {
      print('Search error: $error');
      // Fallback to local filtering if API fails
      _applyFilters();
    }
  }

  void _handleSearchSubmit() {
    _performSearch();
  }

  void _applyFilters() {
    // Get products from the same provider as home page
    final productsState = ref.read(productsProvider);
    final allProducts = productsState.products;
    
    List<Product> filtered = List.from(allProducts);
    
    // Apply search filter (local filtering for empty search)
    final searchQuery = _searchController.text.toLowerCase().trim();
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((product) {
        return product.name.toLowerCase().contains(searchQuery) ||
               product.description.toLowerCase().contains(searchQuery) ||
               product.materialName.toLowerCase().contains(searchQuery) ||
               product.categoryName.toLowerCase().contains(searchQuery) ||
               product.industryName.toLowerCase().contains(searchQuery);
      }).toList();
    }
    
    // Apply material filter (Ferrous/Non-Ferrous)
    if (_selectedMaterial == 'Ferrous') {
      filtered = filtered.where((product) => product.isFerrous).toList();
    } else if (_selectedMaterial == 'Non-Ferrous') {
      filtered = filtered.where((product) => !product.isFerrous).toList();
    }
    
    // Apply category filter
    if (_selectedCategory != 'all') {
      filtered = filtered.where((product) => product.categoryName == _selectedCategory).toList();
    }
    
    // Apply industry filter
    if (_selectedIndustry != 'all') {
      filtered = filtered.where((product) => product.industryName == _selectedIndustry).toList();
    }
    
    // Apply sorting
    switch (_sortBy) {
      case 'name_asc':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'name_desc':
        filtered.sort((a, b) => b.name.compareTo(a.name));
        break;
      case 'stock_asc':
        filtered.sort((a, b) => a.totalStock.compareTo(b.totalStock));
        break;
      case 'stock_desc':
        filtered.sort((a, b) => b.totalStock.compareTo(a.totalStock));
        break;
      default: // relevance - keep original order
        break;
    }
    
    setState(() {
      _filteredProducts = filtered;
    });
  }

  Future<void> _addToCart(Product product) async {
    if (_addingId != null) return;
    setState(() {
      _addingId = product.id;
    });
    try {
      await ApiClient().post(
        '/carts/items',
        data: {'product_id': product.id, 'quantity': 1},
      );
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

  void _clearSearch() {
    _searchController.clear();
    _applyFilters(); // This will show all products
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: (_) => _applyFilters(),
        onSubmitted: (_) => _handleSearchSubmit(),
        onTap: () {
          // Trigger search if there's already text, like in temp.dart
          if (_searchController.text.trim().length > 1) {
            _performSearch();
          }
        },
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: 'Search products, categories, materials...',
          hintStyle: const TextStyle(
            color: Color(0xFF9E9E9E),
            fontSize: 16,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFF00695C),
            size: 24,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Color(0xFF666666)),
                  onPressed: _clearSearch,
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    // Get products from the same provider as home page
    final productsState = ref.watch(productsProvider);
    final allProducts = productsState.products;
    
    // Get unique categories and industries from products
    final categories = allProducts.map((p) => p.categoryName).toSet().toList()..sort();
    final industries = allProducts.map((p) => p.industryName).toSet().toList()..sort();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filters',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF00695C),
            ),
          ),
          const SizedBox(height: 12),
          // Material Filter (Ferrous/Non-Ferrous)
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedMaterial,
                  decoration: const InputDecoration(
                    labelText: 'Material Type',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Materials')),
                    DropdownMenuItem(value: 'Ferrous', child: Text('Ferrous')),
                    DropdownMenuItem(value: 'Non-Ferrous', child: Text('Non-Ferrous')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedMaterial = value ?? 'all';
                    });
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _sortBy,
                  decoration: const InputDecoration(
                    labelText: 'Sort By',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'relevance', child: Text('Relevance')),
                    DropdownMenuItem(value: 'name_asc', child: Text('Name (A-Z)')),
                    DropdownMenuItem(value: 'name_desc', child: Text('Name (Z-A)')),
                    DropdownMenuItem(value: 'stock_asc', child: Text('Stock (Low to High)')),
                    DropdownMenuItem(value: 'stock_desc', child: Text('Stock (High to Low)')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value ?? 'relevance';
                    });
                    _applyFilters();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Category and Industry Filters
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    const DropdownMenuItem(value: 'all', child: Text('All Categories')),
                    ...categories.map((cat) => DropdownMenuItem(
                      value: cat,
                      child: Text(cat),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value ?? 'all';
                    });
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedIndustry,
                  decoration: const InputDecoration(
                    labelText: 'Industry',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    const DropdownMenuItem(value: 'all', child: Text('All Industries')),
                    ...industries.map((ind) => DropdownMenuItem(
                      value: ind,
                      child: Text(ind),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedIndustry = value ?? 'all';
                    });
                    _applyFilters();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildSearchResults() {
    // Use the same provider pattern as home page
    final productsState = ref.watch(productsProvider);
    final allProducts = productsState.products;
    
    if (!productsState.loaded && allProducts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 64,
              color: Color(0xFF9E9E9E),
            ),
            const SizedBox(height: 16),
            const Text(
              'No products found',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF9E9E9E),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.trim().isNotEmpty
                  ? 'Try adjusting your search terms or filters'
                  : 'No products available',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF9E9E9E),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                '${_filteredProducts.length} products found',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
              const Spacer(),
              if (_searchController.text.trim().isNotEmpty)
                Text(
                  'for "${_searchController.text}"',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filteredProducts.length,
            itemBuilder: (context, index) {
              final product = _filteredProducts[index];
              return ProductCard(
                product: product,
                onView: () => Navigator.pushNamed(
                  context,
                  '/product',
                  arguments: product,
                ),
                onAddToCart: () => _addToCart(product),
                isAdding: _addingId == product.id,
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        leadingWidth: 56,
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF00695C),
          ),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/home');
            }
          },
        ),
        title: const Text(
          'Search Products',
          style: TextStyle(
            color: Color(0xFF00695C),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          _buildSearchBar(),
          _buildFilters(),
          const SizedBox(height: 16),
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }
}
