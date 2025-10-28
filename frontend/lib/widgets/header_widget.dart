import 'package:flutter/material.dart';

class HeaderWidget extends StatelessWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const HeaderWidget({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Стрелка назад слева
          if (showBackButton)
            Positioned(
              left: 0,
              child: GestureDetector(
                onTap: onBackPressed ?? () => Navigator.pop(context),
                child: _buildBackArrow(),
              ),
            ),

          // Заголовок по центру
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCupcakeIcon(),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 32,
                  color: Color.fromRGBO(111, 120, 124, 1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackArrow() {
    return Container(
      width: 80,
      height: 80,
      child: const Icon(Icons.arrow_back, size: 28, color: Colors.black),
    );
  }

  Widget _buildCupcakeIcon() {
    return const Icon(Icons.cake, size: 36, color: Colors.pink);
  }
}
