import 'package:flutter/material.dart';
import '../../widgets/header_widget.dart';
import '../../services/users_service.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  List<dynamic> _addresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    try {
      final result = await UsersService.getAddresses();
      if (result['success'] && result['data'] != null) {
        final addresses = (result['data'] as List).map((serverAddress) {
          return _convertFromServerFormat(serverAddress);
        }).toList();

        setState(() {
          _addresses = addresses;
        });
      } else {
        if (result['needsAuth'] == true) {
          _showErrorSnackBar('Требуется авторизация');
        } else {
          _showErrorSnackBar(result['message'] ?? 'Ошибка загрузки адресов');
        }
      }
    } catch (e) {
      print('Ошибка загрузки адресов: $e');
      _showErrorSnackBar('Ошибка загрузки адресов');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _convertFromServerFormat(
    Map<String, dynamic> serverData,
  ) {
    return {
      'id': serverData['id'],
      'title': serverData['title'] ?? '',
      'street': serverData['street'] ?? '',
      'houseNumber':
          serverData['house_number'] ?? serverData['houseNumber'] ?? '',
      'apartmentNumber':
          serverData['apartment_number'] ?? serverData['apartmentNumber'] ?? '',
      'floor': serverData['floor'] ?? 0,
      'entrance': serverData['entrance'] ?? '',
      'doorcode': serverData['doorcode'] ?? '',
      'comment': serverData['comment'] ?? '',
      'isPrimary': serverData['is_primary'] ?? serverData['isPrimary'] ?? false,
    };
  }

  Future<void> _deleteAddress(String addressId) async {
    try {
      final result = await UsersService.deleteAddress(addressId);
      if (result['success']) {
        setState(() {
          _addresses.removeWhere(
            (address) =>
                address['id'] == addressId || address['_id'] == addressId,
          );
        });
        _showSuccessSnackBar('Адрес удален');
      } else {
        if (result['needsAuth'] == true) {
          _showErrorSnackBar('Требуется авторизация');
        } else {
          _showErrorSnackBar(result['message'] ?? 'Ошибка удаления адреса');
        }
      }
    } catch (e) {
      _showErrorSnackBar('Ошибка удаления адреса: $e');
    }
  }

  void _showDeleteConfirmation(String addressId, String addressTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удаление адреса'),
        content: Text('Вы уверены, что хотите удалить адрес "$addressTitle"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAddress(addressId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(242, 221, 233, 1),
      body: Column(
        children: [
          const HeaderWidget(title: 'Адреса доставки', showBackButton: true),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color.fromRGBO(55, 121, 149, 1),
                    ),
                  )
                : _addresses.isEmpty
                ? _buildEmptyAddresses()
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      ..._addresses.map(
                        (address) => _buildAddressCard(address),
                      ),
                      const SizedBox(height: 32),
                      _buildAddAddressButton(context),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyAddresses() {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 100,
                  color: Color.fromRGBO(111, 120, 124, 0.5),
                ),
                const SizedBox(height: 24),
                Text(
                  'Адреса не добавлены',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(111, 120, 124, 1),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Добавьте адрес для удобства заказов',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromRGBO(111, 120, 124, 0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildAddAddressButton(context),
        ),
      ],
    );
  }

  Widget _buildAddressCard(Map<String, dynamic> address) {
    final addressId = address['id'] ?? address['_id'];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.location_on,
              color: Color.fromRGBO(55, 121, 149, 1),
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        address['title'] ?? 'Адрес',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(111, 120, 124, 1),
                        ),
                      ),
                      if (address['isPrimary'] == true) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(55, 121, 149, 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Основной',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color.fromRGBO(55, 121, 149, 1),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatAddress(address),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color.fromRGBO(111, 120, 124, 0.8),
                    ),
                  ),
                  if (address['comment'] != null &&
                      address['comment'].isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Комментарий: ${address['comment']}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color.fromRGBO(111, 120, 124, 0.6),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: Color.fromRGBO(55, 121, 149, 1),
              ),
              onSelected: (value) {
                if (value == 'edit') {
                  _editAddress(address);
                } else if (value == 'delete') {
                  _showDeleteConfirmation(
                    addressId.toString(),
                    address['title'] ?? 'Адрес',
                  );
                } else if (value == 'set_primary') {
                  _setPrimaryAddress(addressId.toString());
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Редактировать'),
                    ],
                  ),
                ),
                if (address['isPrimary'] != true)
                  const PopupMenuItem(
                    value: 'set_primary',
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

  String _formatAddress(Map<String, dynamic> address) {
    final parts = [
      address['street'],
      address['houseNumber'],
      address['apartmentNumber'] != null &&
              address['apartmentNumber'].isNotEmpty
          ? 'кв. ${address['apartmentNumber']}'
          : null,
      address['entrance'] != null && address['entrance'].isNotEmpty
          ? 'под. ${address['entrance']}'
          : null,
      address['floor'] != null && address['floor'] > 0
          ? 'эт. ${address['floor']}'
          : null,
    ].where((part) => part != null && part.isNotEmpty).toList();

    return parts.join(', ');
  }

  void _editAddress(Map<String, dynamic> address) {
    _showAddEditAddressDialog(address: address);
  }

  Future<void> _setPrimaryAddress(String addressId) async {
    try {
      final result = await UsersService.updateAddress(addressId, {
        'isPrimary': true,
      });

      if (result['success']) {
        _showSuccessSnackBar('Основной адрес обновлен');
        await _loadAddresses();
      } else {
        if (result['needsAuth'] == true) {
          _showErrorSnackBar('Требуется авторизация');
        } else {
          _showErrorSnackBar(result['message'] ?? 'Ошибка обновления адреса');
        }
      }
    } catch (e) {
      _showErrorSnackBar('Ошибка обновления адреса: $e');
    }
  }

  Widget _buildAddAddressButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: () {
          _showAddEditAddressDialog();
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
              'Добавить адрес',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEditAddressDialog({Map<String, dynamic>? address}) {
    final isEditing = address != null;

    final titleController = TextEditingController(
      text: address?['title'] ?? '',
    );
    final streetController = TextEditingController(
      text: address?['street'] ?? '',
    );
    final houseNumberController = TextEditingController(
      text: address?['houseNumber'] ?? '',
    );
    final apartmentNumberController = TextEditingController(
      text: address?['apartmentNumber']?.toString() ?? '',
    );
    final entranceController = TextEditingController(
      text: address?['entrance']?.toString() ?? '',
    );
    final floorController = TextEditingController(
      text: address?['floor']?.toString() ?? '',
    );
    final doorcodeController = TextEditingController(
      text: address?['doorcode'] ?? '',
    );
    final commentController = TextEditingController(
      text: address?['comment'] ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          bool _isSaving = false;

          return AlertDialog(
            title: Text(isEditing ? 'Редактировать адрес' : 'Добавить адрес'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Название адреса *',
                      hintText: 'Например: Дом, Работа',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: streetController,
                    decoration: const InputDecoration(labelText: 'Улица *'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: houseNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Номер дома *',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: apartmentNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Номер квартиры',
                    ),
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: entranceController,
                    decoration: const InputDecoration(labelText: 'Подъезд'),
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: floorController,
                    decoration: const InputDecoration(labelText: 'Этаж'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: doorcodeController,
                    decoration: const InputDecoration(
                      labelText: 'Код домофона',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: commentController,
                    decoration: const InputDecoration(
                      labelText: 'Комментарий для курьера',
                    ),
                    maxLines: 2,
                  ),
                  if (!isEditing) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Checkbox(
                          value: _addresses.isEmpty,
                          onChanged: _addresses.isEmpty ? null : (value) {},
                        ),
                        const Text('Сделать основным адресом'),
                      ],
                    ),
                    if (_addresses.isEmpty)
                      const Text(
                        'Первый адрес будет основным по умолчанию',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: _isSaving ? null : () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
              ElevatedButton(
                onPressed: _isSaving
                    ? null
                    : () async {
                        final title = titleController.text.trim();
                        final street = streetController.text.trim();
                        final houseNumber = houseNumberController.text.trim();

                        if (title.isEmpty) {
                          _showErrorSnackBar('Введите название адреса');
                          return;
                        }
                        if (street.isEmpty) {
                          _showErrorSnackBar('Введите улицу');
                          return;
                        }
                        if (houseNumber.isEmpty) {
                          _showErrorSnackBar('Введите номер дома');
                          return;
                        }

                        setDialogState(() {
                          _isSaving = true;
                        });

                        final addressData = {
                          'title': title,
                          'street': street,
                          'houseNumber': houseNumber,
                          'apartmentNumber': apartmentNumberController.text
                              .trim(),
                          'entrance': entranceController.text.trim(),
                          'floor': floorController.text.trim().isNotEmpty
                              ? int.tryParse(floorController.text.trim()) ?? 0
                              : 0,
                          'doorcode': doorcodeController.text.trim(),
                          'comment': commentController.text.trim(),
                          'isPrimary': isEditing
                              ? address!['isPrimary']
                              : _addresses.isEmpty,
                        };

                        try {
                          final result = isEditing
                              ? await UsersService.updateAddress(
                                  address!['id'].toString(),
                                  addressData,
                                )
                              : await UsersService.addAddress(addressData);

                          if (result['success']) {
                            Navigator.pop(context);
                            _showSuccessSnackBar(
                              isEditing ? 'Адрес обновлен' : 'Адрес добавлен',
                            );
                            await _loadAddresses();
                          } else {
                            if (result['needsAuth'] == true) {
                              _showErrorSnackBar('Требуется авторизация');
                            } else {
                              _showErrorSnackBar(
                                result['message'] ?? 'Ошибка сохранения адреса',
                              );
                            }
                          }
                        } catch (e) {
                          _showErrorSnackBar('Ошибка сохранения адреса: $e');
                        } finally {
                          setDialogState(() {
                            _isSaving = false;
                          });
                        }
                      },
                child: _isSaving
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(isEditing ? 'Сохранить' : 'Добавить'),
              ),
            ],
          );
        },
      ),
    );
  }
}
