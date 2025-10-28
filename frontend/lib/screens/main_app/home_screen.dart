import 'package:flutter/material.dart';
import '../../widgets/header_widget.dart';
import '../product/product_detail_screen.dart';
import '../main_app/menu_screen.dart';
import '../../models/product.dart';
import '../../services/products_service.dart';
import '../../services/cart_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> _featuredProducts = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadFeaturedProducts();
  }

  Future<void> _loadFeaturedProducts() async {
    try {
      print('🔄 HomeScreen: Loading featured products...');

      final popularResult = await ProductsService.getPopularProducts();

      if (popularResult['success'] == true) {
        final data = popularResult['data'];
        print('📊 Popular products data type: ${data.runtimeType}');

        if (data != null) {
          final products = _parseProductsList(data);
          if (products.isNotEmpty) {
            print('✅ Popular products loaded: ${products.length} items');
            setState(() {
              _featuredProducts = products;
              _isLoading = false;
            });
            return;
          }
        }
      }

      print('🔄 Falling back to regular products...');
      await _loadRegularProducts();
    } catch (e) {
      print('❌ Error in _loadFeaturedProducts: $e');
      await _loadRegularProducts();
    }
  }

  Future<void> _loadRegularProducts() async {
    try {
      print('🔄 Loading regular products...');
      final result = await ProductsService.getProducts(limit: 6);

      if (result['success'] == true) {
        final data = result['data'];
        print('📊 Regular products data type: ${data.runtimeType}');

        if (data != null) {
          final products = _parseProductsList(data);
          print('✅ Regular products loaded: ${products.length} items');
          setState(() {
            _featuredProducts = products;
            _isLoading = false;
          });
        } else {
          _handleError('Нет данных о товарах');
        }
      } else {
        _handleError(result['message'] ?? 'Ошибка загрузки товаров');
      }
    } catch (e) {
      print('❌ Error in _loadRegularProducts: $e');
      _handleError('Ошибка загрузки: $e');
    }
  }

  List<Product> _parseProductsList(dynamic data) {
    try {
      List<dynamic> items = [];

      if (data is List) {
        items = data;
      } else if (data is Map<String, dynamic>) {
        items = data['products'] ?? data['items'] ?? data['data'] ?? [data];
      } else {
        items = [data];
      }

      final products = items
          .map((item) => _parseProduct(item))
          .where((product) => product != null)
          .cast<Product>()
          .toList();

      print('🔄 Parsed ${products.length} products from ${items.length} items');
      return products;
    } catch (e) {
      print('❌ Error parsing products list: $e');
      return [];
    }
  }

  Product? _parseProduct(dynamic item) {
    try {
      if (item is Map<String, dynamic>) {
        return Product.fromJson(item);
      }
      return null;
    } catch (e) {
      print('❌ Error parsing product: $e, item: $item');
      return null;
    }
  }

  void _handleError(String message) {
    print('❌ HomeScreen error: $message');
    setState(() {
      _errorMessage = message;
      _isLoading = false;
    });
  }

  void _retryLoading() {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    _loadFeaturedProducts();
  }

  @override
  Widget build(BuildContext context) {
    final cartService = CartService();

    return Scaffold(
      backgroundColor: const Color.fromRGBO(242, 221, 233, 1),
      body: Column(
        children: [
          const HeaderWidget(title: 'Главная', showBackButton: false),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeSection(),
                  const SizedBox(height: 32),
                  _buildPromoSection(),
                  const SizedBox(height: 32),
                  _buildFeaturedProducts(context, cartService),
                  const SizedBox(height: 32),
                  _buildQuickOrderSection(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ешь и наслаждайся!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(111, 120, 124, 1),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Качественные десерты',
            style: TextStyle(
              fontSize: 16,
              color: Color.fromRGBO(111, 120, 124, 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Акции',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(111, 120, 124, 1),
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildPromoCard(
                'Скидка 20%',
                'На все кофе по понедельникам',
                'assets/images/kofe20.jpg',
              ),
              const SizedBox(width: 16),
              _buildPromoCard(
                'Приведи друга',
                'Получи второй кофе в подарок',
                'assets/images/sotr.png',
              ),
              const SizedBox(width: 16),
              _buildPromoCard(
                'Комбо обед',
                'Кофе + десерт = специальная цена',
                'assets/images/promo_combo.jpg',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPromoCard(String title, String subtitle, String imagePath) {
    return Container(
      width: 280,
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.6), Colors.transparent],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedProducts(BuildContext context, CartService cartService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Новинки',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(111, 120, 124, 1),
          ),
        ),
        const SizedBox(height: 16),
        _isLoading
            ? _buildLoadingIndicator()
            : _errorMessage.isNotEmpty
            ? _buildErrorWidget()
            : _featuredProducts.isEmpty
            ? _buildEmptyProducts()
            : Column(
                children: _featuredProducts
                    .map(
                      (product) =>
                          _buildProductItem(product, context, cartService),
                    )
                    .toList(),
              ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            CircularProgressIndicator(color: Color.fromRGBO(55, 121, 149, 1)),
            const SizedBox(height: 16),
            Text(
              'Загружаем товары...',
              style: TextStyle(color: Color.fromRGBO(111, 120, 124, 0.8)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 50, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Ошибка загрузки',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(111, 120, 124, 1),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color.fromRGBO(111, 120, 124, 0.8),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _retryLoading,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromRGBO(55, 121, 149, 1),
              foregroundColor: Colors.white,
            ),
            child: const Text('Попробовать снова'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyProducts() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 50,
            color: Color.fromRGBO(111, 120, 124, 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Товары скоро появятся',
            style: TextStyle(
              fontSize: 16,
              color: Color.fromRGBO(111, 120, 124, 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(
    Product product,
    BuildContext context,
    CartService cartService,
  ) {
    String imageUrl = product.images.isNotEmpty
        ? product.images.first.imageUrl
        : '';

    bool hasValidImage = imageUrl.isNotEmpty && imageUrl.startsWith('http');

    print('🖼️ Product: ${product.name}');
    print('📁 Image URL: $imageUrl');
    print('✅ Has valid image: $hasValidImage');

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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: hasValidImage
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            print('❌ Error loading image: $error');
                            return _buildPlaceholderImage();
                          },
                        )
                      : _buildPlaceholderImage(),
                ),
              ),
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.description ?? 'Описание отсутствует',
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

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.fastfood, color: Colors.grey, size: 40),
      ),
    );
  }

  Widget _buildQuickOrderSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Полное меню',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(111, 120, 124, 1),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Откройте для себя все наши вкусные предложения',
            style: TextStyle(
              fontSize: 14,
              color: Color.fromRGBO(111, 120, 124, 0.8),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(55, 121, 149, 1),
                  Color.fromRGBO(55, 121, 149, 0.8),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(55, 121, 149, 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MenuScreen()),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.restaurant_menu, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'Перейти к меню',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
