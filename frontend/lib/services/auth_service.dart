import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_service.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:3000/api/auth';

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Сохраняем токен после успешного входа
        final token = data['data']['token'];
        await TokenService.saveToken(token, email);
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Ошибка входа'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  static Future<Map<String, dynamic>> register(
    String email,
    String password,
    String firstName,
    String phoneNumber,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'firstName': firstName,
          'phoneNumber': phoneNumber,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        final token = data['data']['token'];
        await TokenService.saveToken(token, email);
        return {'success': true, 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Ошибка регистрации',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  static Future<void> logout() async {
    await TokenService.deleteToken();
  }
}
