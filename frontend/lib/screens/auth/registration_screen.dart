import 'package:flutter/material.dart';
import '../../widgets/header_widget.dart';
import '../../services/auth_service.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(242, 221, 233, 1),
      body: Stack(
        children: [
          _buildBackgroundImage(),

          SafeArea(
            child: Column(
              children: [
                HeaderWidget(title: 'Tolitiki', showBackButton: true),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(35.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // Поле Почта
                        _buildLabelField('Почта'),
                        const SizedBox(height: 8),
                        _buildEmailField(),
                        const SizedBox(height: 20),

                        // Поле Пароль
                        _buildLabelField('Пароль'),
                        const SizedBox(height: 8),
                        _buildPasswordField(),
                        const SizedBox(height: 20),

                        // Поле Имя
                        _buildLabelField('Имя'),
                        const SizedBox(height: 8),
                        _buildNameField(),
                        const SizedBox(height: 20),

                        // Поле Номер телефона
                        _buildLabelField('Телефон'),
                        const SizedBox(height: 8),
                        _buildPhoneField(),
                        const SizedBox(height: 40),

                        // Кнопка Создать аккаунт
                        _buildRegisterButton(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return SizedBox(
      width: double.infinity,
      child: TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(fontSize: 16, color: Colors.black),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          hintText: 'Введите вашу почту',
          hintStyle: const TextStyle(color: Color.fromRGBO(111, 120, 124, 0.6)),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return SizedBox(
      width: double.infinity,
      child: TextFormField(
        controller: _passwordController,
        obscureText: true,
        style: const TextStyle(fontSize: 16, color: Colors.black),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          hintText: 'Введите пароль',
          hintStyle: const TextStyle(color: Color.fromRGBO(111, 120, 124, 0.6)),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return SizedBox(
      width: double.infinity,
      child: TextFormField(
        controller: _nameController,
        style: const TextStyle(fontSize: 16, color: Colors.black),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          hintText: 'Введите ваше имя',
          hintStyle: const TextStyle(color: Color.fromRGBO(111, 120, 124, 0.6)),
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return SizedBox(
      width: double.infinity,
      child: TextFormField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        style: const TextStyle(fontSize: 16, color: Colors.black),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          hintText: 'Введите номер телефона',
          hintStyle: const TextStyle(color: Color.fromRGBO(111, 120, 124, 0.6)),
        ),
      ),
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : () => _handleRegistration(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color.fromRGBO(55, 121, 149, 1),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator()
            : const Text(
                'Создать аккаунт',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Future<void> _handleRegistration(BuildContext context) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    // Базовая валидация
    if (email.isEmpty || password.isEmpty || name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Пожалуйста, заполните все поля'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await AuthService.register(email, password, name, phone);

    setState(() {
      _isLoading = false;
    });

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Аккаунт успешно создан! Проверьте email для подтверждения.',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Возврат на предыдущий экран
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Ошибка регистрации'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildBackgroundImage() {
    return Center(
      child: Image.asset(
        'assets/images/background.png',
        width: 3000,
        height: 700,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.photo, size: 100, color: Colors.white30),
          );
        },
      ),
    );
  }

  Widget _buildLabelField(String text) {
    return SizedBox(
      width: 110,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color.fromRGBO(111, 120, 124, 1),
            ),
          ),
        ),
      ),
    );
  }
}
