import 'package:flutter/material.dart';
import '../../widgets/header_widget.dart';
import '../../models/product.dart';
import '../../services/orders_service.dart';
import '../../services/token_service.dart';
import '../../services/users_service.dart';
import '../../services/cart_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();
  bool _isLoading = false;
  bool _isCreatingOrder = false;
  Map<String, dynamic>? _userAddresses;
  String? _selectedAddressId;

  List<CartItem> get _cartItems => _cartService.cartItems;
  double get _totalPrice => _cartService.totalPrice;

  @override
  void initState() {
    super.initState();
    _loadUserAddresses();
  }

  void _loadUserAddresses() async {
    try {
      final result = await UsersService.getAddresses();
      if (result['success'] == true) {
        setState(() {
          _userAddresses = result['data'];
          if (_userAddresses != null && _userAddresses!['addresses'] is List) {
            final addresses = _userAddresses!['addresses'] as List;
            final primaryAddress = addresses.firstWhere(
              (address) => address['is_primary'] == true,
              orElse: () => addresses.isNotEmpty ? addresses.first : null,
            );
            if (primaryAddress != null) {
              _selectedAddressId = primaryAddress['id'].toString();
            }
          }
        });
      }
    } catch (e) {
      print('Error loading addresses: $e');
    }
  }

  void addToCart(Product product) {
    setState(() {
      _cartService.addToCart(product);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(242, 221, 233, 1),
      body: Column(
        children: [
          const HeaderWidget(title: 'Корзина', showBackButton: false),
          Expanded(
            child: _cartItems.isEmpty ? _buildEmptyCart() : _buildCartContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: const Color.fromRGBO(111, 120, 124, 0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'Корзина пуста',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color.fromRGBO(111, 120, 124, 1),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Добавьте товары из меню',
            style: TextStyle(
              fontSize: 16,
              color: const Color.fromRGBO(111, 120, 124, 0.8),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 200,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                _navigateToMenu(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color.fromRGBO(55, 121, 149, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Перейти к меню',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToMenu(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);

    Future.microtask(() {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/',
        (route) => false,
        arguments: {'selectedTab': 1},
      );
    });
  }

  Widget _buildCartContent() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _cartItems.length,
            itemBuilder: (context, index) {
              return _buildCartItem(_cartItems[index]);
            },
          ),
        ),
        _buildDeliveryInfo(),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Итого:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromRGBO(111, 120, 124, 1),
                    ),
                  ),
                  Text(
                    '${_totalPrice.toInt()} ₽',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(55, 121, 149, 1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isCreatingOrder
                      ? null
                      : () {
                          _showOrderConfirmation(context);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(55, 121, 149, 1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isCreatingOrder
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Оформить заказ',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryInfo() {
    final currentTotalPrice = _totalPrice;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Доставка',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(111, 120, 124, 1),
            ),
          ),
          const SizedBox(height: 8),
          _userAddresses != null && _userAddresses!['addresses'] is List
              ? _buildAddressSelector(currentTotalPrice)
              : const Text(
                  'Добавьте адрес доставки в профиле',
                  style: TextStyle(color: Color.fromRGBO(111, 120, 124, 0.8)),
                ),
        ],
      ),
    );
  }

  Widget _buildAddressSelector(double currentTotalPrice) {
    final addresses = _userAddresses!['addresses'] as List;

    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: _selectedAddressId,
          decoration: const InputDecoration(
            labelText: 'Адрес доставки',
            border: OutlineInputBorder(),
          ),
          items: addresses.map<DropdownMenuItem<String>>((address) {
            final addressText =
                '${address['street']}, д. ${address['house_number']}${address['apartment_number'] != null ? ', кв. ${address['apartment_number']}' : ''}';
            return DropdownMenuItem<String>(
              value: address['id'].toString(),
              child: Text(addressText),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedAddressId = newValue;
            });
          },
        ),
        const SizedBox(height: 8),
        Text(
          'Бесплатная доставка от 500 ₽',
          style: TextStyle(
            color: currentTotalPrice >= 500
                ? Colors.green
                : const Color.fromRGBO(111, 120, 124, 0.8),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCartItem(CartItem cartItem) {
    String imageUrl = cartItem.product.images.isNotEmpty
        ? cartItem.product.images.first.imageUrl
        : 'assets/images/placeholder.jpg';

    bool isNetworkImage = imageUrl.startsWith('http');

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
                image: isNetworkImage
                    ? DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      )
                    : DecorationImage(
                        image: AssetImage(imageUrl),
                        fit: BoxFit.cover,
                      ),
              ),
              child: cartItem.product.images.isEmpty
                  ? const Icon(Icons.fastfood_outlined, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.product.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(111, 120, 124, 1),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${cartItem.product.price.toInt()} ₽',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color.fromRGBO(55, 121, 149, 1),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${cartItem.totalPrice.toInt()} ₽',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color.fromRGBO(111, 120, 124, 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color.fromRGBO(55, 121, 149, 1),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 18),
                    onPressed: () {
                      _updateQuantity(cartItem, cartItem.quantity - 1);
                    },
                  ),
                  Text(
                    '${cartItem.quantity}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(111, 120, 124, 1),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 18),
                    onPressed: () {
                      _updateQuantity(cartItem, cartItem.quantity + 1);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              onPressed: () {
                _removeItem(cartItem);
              },
              icon: const Icon(Icons.delete_outline, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  void _updateQuantity(CartItem item, int newQuantity) {
    if (newQuantity <= 0) {
      _removeItem(item);
      return;
    }

    setState(() {
      _cartService.updateQuantity(item.product, newQuantity);
    });
  }

  void _removeItem(CartItem item) {
    setState(() {
      _cartService.removeFromCart(item.product);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.product.name} удален из корзины'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showOrderConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Подтверждение заказа'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Оформить заказ на ${_totalPrice.toInt()} ₽?'),
            const SizedBox(height: 8),
            const Text(
              'После подтверждения с вами свяжется оператор для уточнения деталей.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _createOrder();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(55, 121, 149, 1),
            ),
            child: const Text('Подтвердить'),
          ),
        ],
      ),
    );
  }

  Future<void> _createOrder() async {
    if (_isCreatingOrder) return;

    setState(() {
      _isCreatingOrder = true;
    });

    try {
      final hasToken = await TokenService.hasToken();
      if (!hasToken) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Для оформления заказа необходимо авторизоваться'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_cartItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Корзина пуста'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final deliveryAddress = await _getDeliveryAddress();

      final orderData = {
        'items': _cartItems
            .map(
              (item) => {
                'productId': item.product.id,
                'quantity': item.quantity,
                'price': item.product.price,
                'itemTotal': item.totalPrice,
              },
            )
            .toList(),
        'totalAmount': _totalPrice,
        'deliveryAddress': deliveryAddress,
        'paymentMethod': 'card',
      };

      print('📦 Creating order with data: $orderData');

      final result = await OrdersService.createOrder(orderData);

      if (result['success'] == true) {
        setState(() {
          _cartService.clearCart();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Заказ успешно оформлен!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        _showOrderSuccessDialog(result['data']);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Ошибка оформления заказа'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('❌ Order creation error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isCreatingOrder = false;
      });
    }
  }

  Future<Map<String, dynamic>> _getDeliveryAddress() async {
    if (_selectedAddressId != null && _userAddresses != null) {
      final addresses = _userAddresses!['addresses'] as List;
      final selectedAddress = addresses.firstWhere(
        (address) => address['id'].toString() == _selectedAddressId,
        orElse: () => null,
      );

      if (selectedAddress != null) {
        return {
          'street': selectedAddress['street'],
          'house': selectedAddress['house_number'],
          'apartment': selectedAddress['apartment_number'],
          'floor': selectedAddress['floor'],
          'entrance': selectedAddress['entrance'],
          'doorcode': selectedAddress['doorcode'],
          'comment': selectedAddress['comment'],
        };
      }
    }

    return {
      'street': 'ул. Примерная',
      'house': '123',
      'apartment': '45',
      'comment': 'Доставка до двери',
    };
  }

  void _showOrderSuccessDialog(Map<String, dynamic>? orderData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Заказ оформлен!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Номер заказа: #${orderData?['order_number'] ?? '---'}'),
            const SizedBox(height: 8),
            Text('Сумма: ${_totalPrice.toInt()} ₽'),
            const SizedBox(height: 8),
            Text('Статус: ${orderData?['status'] ?? 'обрабатывается'}'),
            const SizedBox(height: 16),
            const Text(
              'Спасибо за заказ! Мы свяжемся с вами для подтверждения.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('На главную'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(55, 121, 149, 1),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
