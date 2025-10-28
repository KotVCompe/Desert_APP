import 'package:flutter/material.dart';
import '../../widgets/header_widget.dart';
import '../../services/orders_service.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<dynamic> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrderHistory();
  }

  Future<void> _loadOrderHistory() async {
    try {
      final result = await OrdersService.getOrderHistory();
      if (result['success'] && result['data'] != null) {
        final orders = (result['data'] as List).map((order) {
          return _convertOrderToStandardFormat(order);
        }).toList();

        setState(() {
          _orders = orders;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'Ошибка загрузки истории заказов',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Ошибка загрузки истории заказов: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка загрузки истории заказов: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _convertOrderToStandardFormat(
    Map<String, dynamic> order,
  ) {
    return {
      'id': order['id'] ?? order['_id'],
      'status': order['status'] ?? '',
      'totalAmount':
          order['total_amount'] ?? order['totalAmount'] ?? order['total'] ?? 0,
      'createdAt':
          order['created_at'] ?? order['createdAt'] ?? order['date'] ?? '',
      'items': _convertOrderItems(order),
    };
  }

  List<dynamic> _convertOrderItems(Map<String, dynamic> order) {
    dynamic items = order['items'] ?? order['products'] ?? [];

    if (items is! List) {
      items = [items];
    }

    return items.map((item) {
      return {
        'productName':
            item['product_name'] ??
            item['productName'] ??
            item['name'] ??
            'Товар',
        'quantity': item['quantity'] ?? 1,
        'price': item['price'] ?? 0,
      };
    }).toList();
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'В обработке';
      case 'confirmed':
        return 'Подтвержден';
      case 'preparing':
        return 'Готовится';
      case 'ready':
        return 'Готов';
      case 'delivering':
        return 'Доставляется';
      case 'delivered':
        return 'Доставлен';
      case 'cancelled':
      case 'canceled':
        return 'Отменен';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.blueAccent;
      case 'ready':
        return Colors.green;
      case 'delivering':
        return Colors.lightGreen;
      case 'delivered':
        return const Color.fromRGBO(55, 121, 149, 1);
      case 'cancelled':
      case 'canceled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(242, 221, 233, 1),
      body: Column(
        children: [
          const HeaderWidget(title: 'История заказов', showBackButton: true),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color.fromRGBO(55, 121, 149, 1),
                    ),
                  )
                : _orders.isEmpty
                ? _buildEmptyOrders()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _orders.length,
                    itemBuilder: (context, index) {
                      return _buildOrderCard(_orders[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyOrders() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 100,
            color: Color.fromRGBO(111, 120, 124, 0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'История заказов пуста',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(111, 120, 124, 1),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Здесь появятся ваши заказы',
            style: TextStyle(
              fontSize: 16,
              color: Color.fromRGBO(111, 120, 124, 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final items = order['items'] ?? [];
    final itemsText = items.isNotEmpty
        ? items
              .map((item) => '${item['productName']} × ${item['quantity']}')
              .join(', ')
        : 'Нет товаров';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Заказ #${order['id'] ?? 'N/A'}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(111, 120, 124, 1),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order['status'] ?? ''),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusText(order['status'] ?? ''),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              itemsText,
              style: const TextStyle(
                fontSize: 16,
                color: Color.fromRGBO(111, 120, 124, 0.8),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(order['totalAmount'] is num ? order['totalAmount'] : 0).toInt()} ₽',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(55, 121, 149, 1),
                  ),
                ),
                Text(
                  _formatDate(order['createdAt']),
                  style: TextStyle(
                    fontSize: 14,
                    color: Color.fromRGBO(111, 120, 124, 0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return '';

    try {
      final dateString = dateValue.toString();
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    } catch (e) {
      return dateValue.toString();
    }
  }
}
