import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/header_widget.dart';
import '../../models/product.dart';
import '../../services/cart_service.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final cartService = Provider.of<CartService>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color.fromRGBO(242, 221, 233, 1),
      body: SafeArea(
        child: Column(
          children: [
            HeaderWidget(title: product.name, showBackButton: true),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProductImage(product),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(111, 120, 124, 1),
                            ),
                          ),
                        ),
                        Text(
                          '${product.price.toInt()} ₽',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(55, 121, 149, 1),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (product.description != null) ...[
                      Text(
                        product.description!,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color.fromRGBO(111, 120, 124, 0.9),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (product.fullDescription != null) ...[
                      _buildSectionTitle('Описание'),
                      const SizedBox(height: 8),
                      Text(
                        product.fullDescription!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color.fromRGBO(111, 120, 124, 0.8),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (product.ingredients.isNotEmpty) ...[
                      _buildSectionTitle('Ингредиенты'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: product.ingredients.map((ingredient) {
                          return Chip(
                            label: Text(
                              ingredient,
                              style: const TextStyle(fontSize: 14),
                            ),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (product.calories != null ||
                        product.weightGrams != null) ...[
                      _buildSectionTitle('Пищевая ценность'),
                      const SizedBox(height: 8),
                      _buildNutritionInfo(product),
                      const SizedBox(height: 24),
                    ],
                    _buildAddToCartButton(context, cartService, product),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(Product product) {
    print('🖼️ Building product image for: ${product.name}');
    print('📸 Images count: ${product.images.length}');

    if (product.images.isEmpty) {
      print('⚠️ No images available for product');
      return _buildPlaceholderImage();
    }

    final imageUrl = product.images.first.imageUrl;
    final isNetworkImage = imageUrl.startsWith('http');

    print('🌐 Image URL: $imageUrl');
    print('🔗 Is network image: $isNetworkImage');

    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey[200],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: isNetworkImage
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  print('❌ Error loading product image: $error');
                  return _buildPlaceholderImage();
                },
              )
            : Image.asset(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print('❌ Error loading asset image: $error');
                  return _buildPlaceholderImage();
                },
              ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(Icons.fastfood, size: 80, color: Colors.grey[400]),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color.fromRGBO(111, 120, 124, 1),
      ),
    );
  }

  Widget _buildNutritionInfo(Product product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          if (product.weightGrams != null)
            _buildNutritionItem('Вес', '${product.weightGrams}г'),
          if (product.calories != null)
            _buildNutritionItem('Ккал', '${product.calories}'),
          if (product.volumeMl != null)
            _buildNutritionItem('Объем', '${product.volumeMl}мл'),
        ],
      ),
    );
  }

  Widget _buildNutritionItem(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(55, 121, 149, 1),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Color.fromRGBO(111, 120, 124, 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildAddToCartButton(
    BuildContext context,
    CartService cartService,
    Product product,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: () {
          cartService.addToCart(product);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${product.name} добавлен в корзину'),
              backgroundColor: Colors.green,
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color.fromRGBO(55, 121, 149, 1),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text(
          'Добавить в корзину',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
