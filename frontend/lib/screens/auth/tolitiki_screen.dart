import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'registration_screen.dart';
import '../../widgets/header_widget.dart';

class TolitikiScreen extends StatelessWidget {
  const TolitikiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(242, 221, 233, 1), // Розовый фон
      body: Stack(
        children: [
          _buildBackgroundImage(),

          SafeArea(
            child: Column(
              children: [
                // Шапка
                HeaderWidget(title: 'Tolitiki', showBackButton: true),

                // Основной контент с кнопками
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const Spacer(flex: 3),

                        // Кнопка Вход
                        _buildLoginButton(context),

                        const SizedBox(height: 80),

                        // Кнопка Регистрация
                        _buildRegistrationButton(context),

                        const Spacer(flex: 4),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Виджет для фонового изображения
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

  Widget _buildLoginButton(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 280,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            foregroundColor: const Color.fromRGBO(55, 121, 149, 1),
            padding: const EdgeInsets.symmetric(vertical: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          child: const Text(
            'Вход',
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildRegistrationButton(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 280,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RegistrationScreen(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            foregroundColor: const Color.fromRGBO(55, 121, 149, 1),
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          child: const Text(
            'Регистрация',
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
