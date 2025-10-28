import 'package:flutter/material.dart';
import '../../widgets/header_widget.dart';
import '../main_app/main_screen.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                HeaderWidget(title: 'Вход', showBackButton: true),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(35.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 30),

                        // Поле Почта
                        _buildLabelField('Почта'),
                        const SizedBox(height: 12),
                        _buildEmailField(),
                        const SizedBox(height: 25),

                        // Поле Пароль
                        _buildLabelField('Пароль'),
                        const SizedBox(height: 12),
                        _buildPasswordField(),
                        const SizedBox(height: 50),

                        // Кнопка Войти
                        _buildLoginButton(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Индикатор загрузки
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
      height: 65,
      child: TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(fontSize: 20, color: Colors.black),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 25,
            vertical: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          hintText: 'Введите вашу почту',
          hintStyle: const TextStyle(
            fontSize: 18,
            color: Color.fromRGBO(111, 120, 124, 0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return SizedBox(
      width: double.infinity,
      height: 65,
      child: TextFormField(
        controller: _passwordController,
        obscureText: true,
        style: const TextStyle(fontSize: 20, color: Colors.black),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 25,
            vertical: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          hintText: 'Введите пароль',
          hintStyle: const TextStyle(
            fontSize: 18,
            color: Color.fromRGBO(111, 120, 124, 0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 70,
      child: ElevatedButton(
        onPressed: _isLoading ? null : () => _handleLogin(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color.fromRGBO(55, 121, 149, 1),
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator()
            : const Text(
                'Войти',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Future<void> _handleLogin(BuildContext context) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Базовая валидация
    if (email.isEmpty || password.isEmpty) {
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

    final result = await AuthService.login(email, password);

    setState(() {
      _isLoading = false;
    });

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Вход выполнен успешно!'),
          backgroundColor: Colors.green,
        ),
      );

      // Навигация на главный экран
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Ошибка входа'),
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
      width: 140,
      height: 55,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Color.fromRGBO(111, 120, 124, 1),
            ),
          ),
        ),
      ),
    );
  }
}
