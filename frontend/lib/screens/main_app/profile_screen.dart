import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import '../../widgets/header_widget.dart';
import '../auth/login_screen.dart';
import '../profile/order_history_screen.dart';
import '../profile/addresses_screen.dart';
import '../profile/notifications_screen.dart';
import '../profile/payment_methods_screen.dart';
import '../profile/help_screen.dart';
import '../../services/users_service.dart';
import '../../services/auth_service.dart';
import '../../services/token_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = '';
  String _userEmail = '';
  String _userPhone = '';
  String? _avatarUrl;
  bool _isLoading = true;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoadProfile();
  }

  Future<void> _checkAuthAndLoadProfile() async {
    try {
      final hasToken = await TokenService.hasToken();
      if (!hasToken) {
        _redirectToLogin();
        return;
      }
      await _loadUserProfile();
    } catch (e) {
      print('Ошибка проверки авторизации: $e');
      _setDefaultValues();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final result = await UsersService.getUserProfile();
      if (result['success'] && result['data'] != null) {
        final userData = result['data'];
        setState(() {
          _userName = userData['firstName'] ?? 'Пользователь';
          _userEmail = userData['email'] ?? 'Email не указан';
          _userPhone = userData['phoneNumber'] ?? 'Телефон не указан';
          _avatarUrl = userData['avatarUrl'];
        });
      } else {
        final hasToken = await TokenService.hasToken();
        if (!hasToken) {
          _redirectToLogin();
        } else {
          _setDefaultValues();
        }
      }
    } catch (e) {
      print('Ошибка загрузки профиля: $e');
      _setDefaultValues();
    }
  }

  void _redirectToLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    });
  }

  void _setDefaultValues() {
    setState(() {
      _userName = 'Пользователь';
      _userEmail = 'Email не указан';
      _userPhone = 'Телефон не указан';
    });
  }

  void _editProfile() {
    showDialog(
      context: context,
      builder: (context) => ProfileEditDialog(
        currentName: _userName,
        currentEmail: _userEmail,
        onSave: (name, email) async {
          final result = await UsersService.updateUserProfile({
            'firstName': name,
            'email': email,
          });

          if (result['success']) {
            setState(() {
              _userName = name;
              _userEmail = email;
            });
            _showSuccessSnackBar('Профиль успешно обновлен');
          } else {
            _showErrorSnackBar(
              result['message'] ?? 'Ошибка обновления профиля',
            );
          }
        },
      ),
    );
  }

  Future<void> _changeAvatar() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Выбрать из галереи'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Сделать фото'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();

        if (!_isValidImage(bytes)) {
          _showErrorSnackBar('Некорректный формат изображения');
          return;
        }

        if (bytes.length > 5 * 1024 * 1024) {
          _showErrorSnackBar('Размер файла не должен превышать 5MB');
          return;
        }

        final filename = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
        await _uploadAvatarBytes(bytes, filename);
      }
    } catch (e) {
      print('Ошибка выбора изображения: $e');
      _showErrorSnackBar('Не удалось выбрать изображение');
    }
  }

  bool _isValidImage(List<int> bytes) {
    if (bytes.length < 8) return false;

    if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) return true;

    if (bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47)
      return true;

    if (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46) return true;

    return false;
  }

  Future<void> _uploadAvatarBytes(Uint8List imageBytes, String filename) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final result = await UsersService.uploadAvatar(imageBytes, filename);

      if (result['success'] == true) {
        if (result['data'] != null && result['data']['avatarUrl'] != null) {
          setState(() {
            _avatarUrl = result['data']['avatarUrl'];
          });
        }
        _showSuccessSnackBar('Аватар успешно обновлен');
        await _loadUserProfile();
      } else {
        _showErrorSnackBar(result['message'] ?? 'Ошибка загрузки аватара');
      }
    } catch (e) {
      print('Ошибка загрузки аватара: $e');
      _showErrorSnackBar('Ошибка загрузки аватара');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
          const HeaderWidget(title: 'Профиль', showBackButton: false),

          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color.fromRGBO(55, 121, 149, 1),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        _buildProfileHeader(),
                        const SizedBox(height: 32),
                        _buildProfileMenu(context),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
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
      child: Row(
        children: [
          GestureDetector(
            onTap: _changeAvatar,
            child: Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color.fromRGBO(242, 221, 233, 1),
                    border: Border.all(
                      color: const Color.fromRGBO(55, 121, 149, 1),
                      width: 2,
                    ),
                    image: _avatarUrl != null
                        ? DecorationImage(
                            image: NetworkImage(_avatarUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _avatarUrl == null
                      ? const Icon(
                          Icons.person,
                          size: 40,
                          color: Color.fromRGBO(55, 121, 149, 1),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(55, 121, 149, 1),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _userName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(111, 120, 124, 1),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _editProfile,
                      icon: Icon(
                        Icons.edit,
                        color: Color.fromRGBO(55, 121, 149, 1),
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _userEmail,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromRGBO(111, 120, 124, 0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _userPhone,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromRGBO(111, 120, 124, 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenu(BuildContext context) {
    return Container(
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
        children: [
          _buildMenuItem(
            icon: Icons.history,
            title: 'История заказов',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OrderHistoryScreen(),
                ),
              );
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.location_on,
            title: 'Адреса доставки',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddressesScreen(),
                ),
              );
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.notifications,
            title: 'Уведомления',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.payment,
            title: 'Способы оплаты',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PaymentMethodsScreen(),
                ),
              );
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.help,
            title: 'Помощь',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpScreen()),
              );
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.logout,
            title: 'Выйти',
            onTap: () {
              _showLogoutConfirmation(context);
            },
            isLogout: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isLogout ? Colors.red : const Color.fromRGBO(55, 121, 149, 1),
        size: 28,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          color: isLogout ? Colors.red : const Color.fromRGBO(111, 120, 124, 1),
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: isLogout ? Colors.red : const Color.fromRGBO(111, 120, 124, 0.6),
        size: 18,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: Color.fromRGBO(111, 120, 124, 0.2)),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выход из аккаунта'),
        content: const Text('Вы уверены, что хотите выйти?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _logout(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) async {
    await AuthService.logout();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Вы вышли из аккаунта'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class ProfileEditDialog extends StatefulWidget {
  final String currentName;
  final String currentEmail;
  final Function(String, String) onSave;

  const ProfileEditDialog({
    super.key,
    required this.currentName,
    required this.currentEmail,
    required this.onSave,
  });

  @override
  State<ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends State<ProfileEditDialog> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _emailController = TextEditingController(text: widget.currentEmail);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  void _saveChanges() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Введите имя'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Введите корректный email'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onSave(name, email);
      Navigator.pop(context);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Редактировать профиль',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(111, 120, 124, 1),
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Имя',
                labelStyle: TextStyle(
                  color: Color.fromRGBO(111, 120, 124, 0.8),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Color.fromRGBO(111, 120, 124, 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Color.fromRGBO(55, 121, 149, 1),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(
                  color: Color.fromRGBO(111, 120, 124, 0.8),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Color.fromRGBO(111, 120, 124, 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Color.fromRGBO(55, 121, 149, 1),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Color.fromRGBO(111, 120, 124, 1),
                      side: BorderSide(
                        color: Color.fromRGBO(111, 120, 124, 0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Отмена'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(55, 121, 149, 1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
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
                        : const Text('Сохранить'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
