import 'package:flutter/material.dart';
import '../../widgets/header_widget.dart';
import '../../services/users_service.dart';
import '../../services/token_service.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  List<dynamic> _paymentMethods = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    final hasToken = await TokenService.hasToken();
    if (!hasToken) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Требуется авторизация для просмотра способов оплаты';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    try {
      setState(() {
        _paymentMethods = [
          {
            'id': '1',
            'type': 'card',
            'title': 'Банковская карта',
            'subtitle': '•••• 1234',
            'isDefault': true,
          },
          {
            'id': '2',
            'type': 'cash',
            'title': 'Наличные',
            'subtitle': 'Оплата при получении',
            'isDefault': false,
          },
        ];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Ошибка загрузки способов оплаты: $e';
      });
    }
  }

  Future<void> _setDefaultPayment(String paymentId) async {
    try {
      setState(() {
        _paymentMethods = _paymentMethods.map((payment) {
          return {...payment, 'isDefault': payment['id'] == paymentId};
        }).toList();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Основной способ оплаты изменен'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка обновления способа оплаты: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deletePayment(String paymentId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удаление способа оплаты'),
        content: const Text(
          'Вы уверены, что хотите удалить этот способ оплаты?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                setState(() {
                  _paymentMethods.removeWhere(
                    (payment) => payment['id'] == paymentId,
                  );
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Способ оплаты удален'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Ошибка удаления способа оплаты: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(242, 221, 233, 1),
      body: Column(
        children: [
          const HeaderWidget(title: 'Способы оплаты', showBackButton: true),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color.fromRGBO(55, 121, 149, 1),
                    ),
                  )
                : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color.fromRGBO(111, 120, 124, 1),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadPaymentMethods,
                          child: const Text('Повторить'),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      ..._paymentMethods.map(
                        (payment) => _buildPaymentCard(payment),
                      ),
                      const SizedBox(height: 32),
                      _buildAddPaymentButton(context),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> payment) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              payment['type'] == 'card'
                  ? Icons.credit_card
                  : Icons.account_balance_wallet,
              color: const Color.fromRGBO(55, 121, 149, 1),
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    payment['title'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(111, 120, 124, 1),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    payment['subtitle'],
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color.fromRGBO(111, 120, 124, 0.8),
                    ),
                  ),
                ],
              ),
            ),
            if (payment['isDefault'])
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(55, 121, 149, 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'По умолчанию',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color.fromRGBO(55, 121, 149, 1),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: const Color.fromRGBO(55, 121, 149, 1),
              ),
              onSelected: (value) {
                if (value == 'set_default' && !payment['isDefault']) {
                  _setDefaultPayment(payment['id']);
                } else if (value == 'delete') {
                  _deletePayment(payment['id']);
                }
              },
              itemBuilder: (context) => [
                if (!payment['isDefault'])
                  const PopupMenuItem(
                    value: 'set_default',
                    child: Row(
                      children: [
                        Icon(Icons.star, size: 20),
                        SizedBox(width: 8),
                        Text('Сделать основным'),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Удалить', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddPaymentButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: () {
          _showAddPaymentDialog(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color.fromRGBO(55, 121, 149, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 24),
            SizedBox(width: 8),
            Text(
              'Добавить способ оплаты',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPaymentDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Функциональность добавления платежного метода в разработке',
        ),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
