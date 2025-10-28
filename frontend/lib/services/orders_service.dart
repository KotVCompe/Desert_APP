import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_service.dart';

class OrdersService {
  static const String baseUrl = 'http://localhost:3000/api/orders';

  static Future<Map<String, String>> _getHeaders() async {
    final token = await TokenService.getToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  static Future<Map<String, dynamic>> createOrder(
    Map<String, dynamic> orderData,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl'),
        headers: headers,
        body: jsonEncode(orderData),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        return {'success': true, 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Ошибка создания заказа',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  static Future<Map<String, dynamic>> getAllOrders() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse('$baseUrl'), headers: headers);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        dynamic ordersData = data['data'];
        if (ordersData is Map<String, dynamic>) {
          ordersData = ordersData['orders'] ?? ordersData['items'] ?? [];
        }
        if (ordersData is! List) {
          ordersData = [ordersData];
        }
        return {'success': true, 'data': ordersData};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Ошибка получения заказов',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  static Future<Map<String, dynamic>> getOrderHistory() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/history'),
        headers: headers,
      );

      print('📥 Order history response status: ${response.statusCode}');
      print('📥 Order history response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        dynamic ordersData = data['data'];

        if (ordersData is Map<String, dynamic>) {
          ordersData = ordersData['orders'] ?? ordersData['items'] ?? [];
        }

        if (ordersData is! List) {
          ordersData = [ordersData];
        }

        print('✅ Orders loaded successfully: ${ordersData.length} items');
        return {'success': true, 'data': ordersData};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Ошибка получения истории заказов',
        };
      }
    } catch (e) {
      print('❌ Error loading order history: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  static Future<Map<String, dynamic>> getOrderById(String orderId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/$orderId'),
        headers: headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Ошибка получения заказа',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  static Future<Map<String, dynamic>> cancelOrder(String orderId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/$orderId/cancel'),
        headers: headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Ошибка отмены заказа',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  static Future<Map<String, dynamic>> confirmDelivery(String orderId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/$orderId/confirm-delivery'),
        headers: headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Ошибка подтверждения доставки',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateOrderStatus(
    String orderId,
    String status,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/$orderId/status'),
        headers: headers,
        body: jsonEncode({'status': status}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Ошибка обновления статуса',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }
}
