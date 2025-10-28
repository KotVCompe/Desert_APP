import 'package:flutter/material.dart';
import '../../widgets/header_widget.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _promoNotifications = true;
  bool _orderNotifications = true;
  bool _systemNotifications = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(242, 221, 233, 1),
      body: Column(
        children: [
          const HeaderWidget(title: 'Уведомления', showBackButton: true),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
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
                  _buildNotificationItem(
                    title: 'Акции и предложения',
                    subtitle:
                        'Уведомления о скидках и специальных предложениях',
                    value: _promoNotifications,
                    onChanged: (value) {
                      setState(() {
                        _promoNotifications = value!;
                      });
                    },
                  ),
                  _buildDivider(),
                  _buildNotificationItem(
                    title: 'Статус заказов',
                    subtitle: 'Уведомления о изменении статуса заказа',
                    value: _orderNotifications,
                    onChanged: (value) {
                      setState(() {
                        _orderNotifications = value!;
                      });
                    },
                  ),
                  _buildDivider(),
                  _buildNotificationItem(
                    title: 'Системные уведомления',
                    subtitle: 'Важные обновления и новости приложения',
                    value: _systemNotifications,
                    onChanged: (value) {
                      setState(() {
                        _systemNotifications = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Color.fromRGBO(111, 120, 124, 1),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 14,
          color: Color.fromRGBO(111, 120, 124, 0.7),
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color.fromRGBO(55, 121, 149, 1),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: Color.fromRGBO(111, 120, 124, 0.2)),
    );
  }
}
