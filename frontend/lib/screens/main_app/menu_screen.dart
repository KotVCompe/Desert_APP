import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/header_widget.dart';
import '../../models/category.dart';
import '../../models/product.dart';
import '../product/product_detail_screen.dart';
import '../../services/products_service.dart';
import '../../services/cart_service.dart';

class CategoryProductsScreen extends StatelessWidget {
  final Category category;
  final List<Product> products;

  const CategoryProductsScreen({
    super.key,
    required this.category,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    final categoryProducts = products
        .where((product) => product.categoryId == category.id)
        .toList();

    print('🔄 Filtering products for category: ${category.name}');
    print('🔍 Category ID: ${category.id} (type: ${category.id.runtimeType})');
    print('📦 Total products: ${products.length}');
    print('✅ Filtered products: ${categoryProducts.length}');

    if (categoryProducts.isEmpty && products.isNotEmpty) {
      print('⚠️ NO PRODUCTS MATCHED!');
      print('🔍 Available category IDs in products:');
      final uniqueCategoryIds = products.map((p) => p.categoryId).toSet();
      print('   $uniqueCategoryIds');
      print('🔍 Current category ID: ${category.id}');
    }

    return Scaffold(
      backgroundColor: const Color.fromRGBO(242, 221, 233, 1),
      body: Column(
        children: [
          HeaderWidget(
            title: '${category.name} (${categoryProducts.length})',
            showBackButton: true,
          ),
          Expanded(
            child: categoryProducts.isEmpty
                ? _buildEmptyProducts()
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: categoryProducts.length,
                    itemBuilder: (context, index) {
                      final product = categoryProducts[index];
                      return _buildProductCard(product, context);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product, BuildContext context) {
    final cartService = Provider.of<CartService>(context, listen: false);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product: product),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildProductImage(product),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(111, 120, 124, 1),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.description ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color.fromRGBO(111, 120, 124, 0.8),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${product.price.toInt()} ₽',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(55, 121, 149, 1),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  cartService.addToCart(product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.name} добавлен в корзину'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(55, 121, 149, 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(Product product) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 80,
        height: 80,
        color: Colors.white,
        child: product.images.isNotEmpty
            ? Image.network(
                product.images.first.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholderIcon();
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                      color: Color.fromRGBO(55, 121, 149, 1),
                    ),
                  );
                },
              )
            : _buildPlaceholderIcon(),
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      color: Color.fromRGBO(242, 221, 233, 1),
      child: Icon(
        Icons.fastfood,
        color: Color.fromRGBO(55, 121, 149, 0.5),
        size: 40,
      ),
    );
  }

  Widget _buildEmptyProducts() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fastfood_outlined,
            size: 64,
            color: Color.fromRGBO(111, 120, 124, 0.5),
          ),
          SizedBox(height: 16),
          Text(
            'Товары скоро появятся',
            style: TextStyle(
              fontSize: 18,
              color: Color.fromRGBO(111, 120, 124, 1),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'В этой категории пока нет товаров',
            style: TextStyle(
              fontSize: 14,
              color: Color.fromRGBO(111, 120, 124, 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<Category> _categories = [];
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      print('Starting data loading...');
      await _loadCategories();
      await _loadProducts();
    } catch (e) {
      print('Error in _loadData: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
      print('Data loading completed');
      print('Categories count: ${_categories.length}');
      print('Products count: ${_products.length}');
    }
  }

  Future<void> _loadCategories() async {
    try {
      final result = await ProductsService.getCategories();
      print('=== CATEGORIES API RESPONSE ===');
      print('Success: ${result['success']}');

      if (result['success'] == true && result['data'] is List) {
        final categoriesData = result['data'] as List;
        print('Number of categories: ${categoriesData.length}');

        final categoriesList = categoriesData.map((item) {
          print('📁 Category: ${item['name']}, ID: ${item['id']}');
          return Category.fromJson(item);
        }).toList();

        setState(() {
          _categories = categoriesList;
        });

        if (_products.isNotEmpty) {
          print('🔍 CATEGORY-PRODUCT MATCHING CHECK:');
          for (var category in categoriesList) {
            final matchingProducts = _products
                .where((product) => product.categoryId == category.id)
                .toList();
            print(
              '   ${category.name} (ID: ${category.id}): ${matchingProducts.length} products',
            );
          }
        }
      } else {
        print('No categories data or success is false');
      }
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  Future<void> _loadProducts() async {
    try {
      final result = await ProductsService.getProducts();
      if (result['success'] == true) {
        final productsList = (result['data'] as List)
            .map((item) => Product.fromJson(item))
            .toList();

        print('=== LOADED PRODUCTS ANALYSIS ===');
        print('📦 Total products loaded: ${productsList.length}');

        if (productsList.isEmpty) {
          print('❌ NO PRODUCTS LOADED!');
        } else {
          final categoryGroups = <int, List<Product>>{};
          for (var product in productsList) {
            final categoryId = product.categoryId;
            if (!categoryGroups.containsKey(categoryId)) {
              categoryGroups[categoryId] = [];
            }
            categoryGroups[categoryId]!.add(product);
          }

          print('📊 Products by category (ID -> Count):');
          categoryGroups.forEach((categoryId, products) {
            print('   Category $categoryId: ${products.length} products');
          });

          print('📋 First product details:');
          final sample = productsList.first;
          print('   ID: ${sample.id}');
          print('   Name: ${sample.name}');
          print(
            '   Category ID: ${sample.categoryId} (type: ${sample.categoryId.runtimeType})',
          );
          print('   Price: ${sample.price}');
          print('   Images: ${sample.images.length}');
        }

        setState(() {
          _products = productsList;
        });
      } else {
        print('❌ Error loading products: ${result['message']}');
      }
    } catch (e) {
      print('❌ Error loading products: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartService = Provider.of<CartService>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color.fromRGBO(242, 221, 233, 1),
      body: Column(
        children: [
          const HeaderWidget(title: 'Меню', showBackButton: true),
          Expanded(
            child: _isLoading
                ? _buildLoadingIndicator()
                : _categories.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 64,
                        color: Color.fromRGBO(111, 120, 124, 0.5),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Категории не найдены',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color.fromRGBO(111, 120, 124, 1),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Проверьте подключение к интернету',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color.fromRGBO(111, 120, 124, 0.7),
                        ),
                      ),
                    ],
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Категории'),
                        const SizedBox(height: 16),
                        _buildCategoriesGrid(context),
                        const SizedBox(height: 32),
                        _buildSectionTitle('Популярное'),
                        const SizedBox(height: 16),
                        _buildProductsList(context, cartService),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(color: Color.fromRGBO(55, 121, 149, 1)),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color.fromRGBO(111, 120, 124, 1),
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        return _buildCategoryCard(category, context);
      },
    );
  }

  Widget _buildCategoryCard(Category category, BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryProductsScreen(
                category: category,
                products: _products,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Color.fromRGBO(55, 121, 149, 0.8),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.6), Colors.transparent],
              ),
              image: category.imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(category.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: Center(
              child: Text(
                category.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductsList(BuildContext context, CartService cartService) {
    final popularProducts = _products.take(3).toList();

    return popularProducts.isEmpty
        ? _buildEmptyProducts()
        : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: popularProducts.length,
            itemBuilder: (context, index) {
              final product = popularProducts[index];
              return _buildProductCardForList(product, context, cartService);
            },
          );
  }

  Widget _buildEmptyProducts() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Text(
        'Товары скоро появятся',
        style: TextStyle(
          fontSize: 16,
          color: Color.fromRGBO(111, 120, 124, 0.8),
        ),
      ),
    );
  }

  Widget _buildProductCardForList(
    Product product,
    BuildContext context,
    CartService cartService,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product: product),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildProductImage(product),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(111, 120, 124, 1),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.description ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color.fromRGBO(111, 120, 124, 0.8),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${product.price.toInt()} ₽',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(55, 121, 149, 1),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  cartService.addToCart(product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.name} добавлен в корзину'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(55, 121, 149, 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(Product product) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 80,
        height: 80,
        color: Colors.white,
        child: product.images.isNotEmpty
            ? Image.network(
                product.images.first.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholderIcon();
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                      color: Color.fromRGBO(55, 121, 149, 1),
                    ),
                  );
                },
              )
            : _buildPlaceholderIcon(),
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      color: Color.fromRGBO(242, 221, 233, 1),
      child: Icon(
        Icons.fastfood,
        color: Color.fromRGBO(55, 121, 149, 0.5),
        size: 40,
      ),
    );
  }
}
