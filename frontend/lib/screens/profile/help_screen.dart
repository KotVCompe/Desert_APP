import 'package:flutter/material.dart';
import '../../widgets/header_widget.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(242, 221, 233, 1),
      body: Column(
        children: [
          const HeaderWidget(title: 'Помощь', showBackButton: true),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHelpItem(
                  icon: Icons.help_outline,
                  title: 'Часто задаваемые вопросы',
                  onTap: () {
                    _showFAQDialog(context);
                  },
                ),
                const SizedBox(height: 16),
                _buildHelpItem(
                  icon: Icons.support_agent,
                  title: 'Служба поддержки',
                  onTap: () {
                    _showSupportDialog(context);
                  },
                ),
                const SizedBox(height: 16),
                _buildHelpItem(
                  icon: Icons.description,
                  title: 'Условия использования',
                  onTap: () {
                    _showTermsDialog(context);
                  },
                ),
                const SizedBox(height: 16),
                _buildHelpItem(
                  icon: Icons.security,
                  title: 'Политика конфиденциальности',
                  onTap: () {
                    _showPrivacyDialog(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        leading: Icon(icon, color: Color.fromRGBO(55, 121, 149, 1), size: 32),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Color.fromRGBO(111, 120, 124, 1),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Color.fromRGBO(111, 120, 124, 0.6),
          size: 18,
        ),
        onTap: onTap,
      ),
    );
  }

  void _showFAQDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Часто задаваемые вопросы'),
        content: const SingleChildScrollView(
          child: Text(
            'Здесь будут ответы на часто задаваемые вопросы о работе приложения, доставке, оплате и т.д.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Служба поддержки'),
        content: const Text(
          'Телефон: +7 (999) 123-45-67\nEmail: support@tolitiki.ru\nВремя работы: 9:00 - 21:00',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Условия использования'),
        content: const SingleChildScrollView(
          child: Text('Здесь будут условия использования приложения...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Политика конфиденциальности'),
        content: const SingleChildScrollView(
          child: Text('Здесь будет политика конфиденциальности...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }
}
