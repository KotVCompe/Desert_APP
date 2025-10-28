import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'token_service.dart';

class UsersService {
  static const String baseUrl = 'http://localhost:3000/api/users';
  static const String serverBaseUrl = 'http://localhost:3000';

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

  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final userData = data['data']['user'];

        if (userData['avatarUrl'] != null) {
          userData['avatarUrl'] = '$serverBaseUrl${userData['avatarUrl']}';
        }

        return {'success': true, 'data': userData};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Ошибка получения профиля',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateUserProfile(
    Map<String, dynamic> profileData,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/profile'),
        headers: headers,
        body: jsonEncode(profileData),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'data': data['data']['user']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Ошибка обновления профиля',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  static Future<Map<String, dynamic>> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/change-password'),
        headers: headers,
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Ошибка смены пароля',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  static Future<Map<String, dynamic>> uploadAvatar(
    List<int> imageBytes,
    String filename,
  ) async {
    try {
      final token = await TokenService.getToken();

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/avatar'),
      );

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      final multipartFile = http.MultipartFile.fromBytes(
        'avatar',
        imageBytes,
        filename: filename,
      );

      request.files.add(multipartFile);

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final data = jsonDecode(responseData);

      if (response.statusCode == 200 && data['success'] == true) {
        final avatarUrl = data['data']['avatarUrl'];
        final fullAvatarUrl = avatarUrl != null
            ? '$serverBaseUrl$avatarUrl'
            : null;

        return {
          'success': true,
          'data': {'avatarUrl': fullAvatarUrl},
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Ошибка загрузки аватара',
        };
      }
    } catch (e) {
      print('Ошибка сети при загрузке аватара: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  static Future<Map<String, dynamic>> getAddresses() async {
    try {
      final headers = await _getHeaders();
      print('🔍 Getting addresses with headers: $headers');

      final response = await http.get(
        Uri.parse('$baseUrl/addresses'),
        headers: headers,
      );

      print('📥 Addresses response status: ${response.statusCode}');
      print('📥 Addresses response body: ${response.body}');

      if (response.statusCode == 401) {
        await TokenService.deleteToken();
        return {
          'success': false,
          'message': 'Требуется авторизация',
          'needsAuth': true,
        };
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        dynamic addressesData = data['data'];

        if (addressesData is Map<String, dynamic>) {
          addressesData = addressesData['addresses'] ?? [];
        }

        if (addressesData is! List) {
          addressesData = [addressesData];
        }

        print('✅ Addresses loaded successfully: ${addressesData.length} items');
        return {'success': true, 'data': addressesData};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Ошибка получения адресов',
        };
      }
    } catch (e) {
      print('❌ Error loading addresses: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  static Future<Map<String, dynamic>> addAddress(
    Map<String, dynamic> addressData,
  ) async {
    try {
      final headers = await _getHeaders();

      final serverData = _convertToServerFormat(addressData);

      print('🔄 Adding address with data: $serverData');
      print('📤 Headers: $headers');

      final response = await http.post(
        Uri.parse('$baseUrl/addresses'),
        headers: headers,
        body: jsonEncode(serverData),
      );

      print('📥 Add address response status: ${response.statusCode}');
      print('📥 Add address response body: ${response.body}');

      if (response.statusCode == 401) {
        await TokenService.deleteToken();
        return {
          'success': false,
          'message': 'Требуется авторизация',
          'needsAuth': true,
        };
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        dynamic responseData = data['data'];
        if (responseData is Map<String, dynamic>) {
          responseData = responseData['address'] ?? responseData;
        }
        return {'success': true, 'data': responseData};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Ошибка добавления адреса',
        };
      }
    } catch (e) {
      print('❌ Error adding address: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateAddress(
    String addressId,
    Map<String, dynamic> addressData,
  ) async {
    try {
      final headers = await _getHeaders();

      final serverData = _convertToServerFormat(addressData);

      print('🔄 Updating address $addressId with data: $serverData');

      final response = await http.put(
        Uri.parse('$baseUrl/addresses/$addressId'),
        headers: headers,
        body: jsonEncode(serverData),
      );

      print('📥 Update address response status: ${response.statusCode}');
      print('📥 Update address response body: ${response.body}');

      if (response.statusCode == 401) {
        await TokenService.deleteToken();
        return {
          'success': false,
          'message': 'Требуется авторизация',
          'needsAuth': true,
        };
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        dynamic responseData = data['data'];
        if (responseData is Map<String, dynamic>) {
          responseData = responseData['address'] ?? responseData;
        }
        return {'success': true, 'data': responseData};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Ошибка обновления адреса',
        };
      }
    } catch (e) {
      print('❌ Error updating address: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteAddress(String addressId) async {
    try {
      final headers = await _getHeaders();
      print('🔄 Deleting address: $addressId');

      final response = await http.delete(
        Uri.parse('$baseUrl/addresses/$addressId'),
        headers: headers,
      );

      print('📥 Delete address response status: ${response.statusCode}');
      print('📥 Delete address response body: ${response.body}');

      if (response.statusCode == 401) {
        await TokenService.deleteToken();
        return {
          'success': false,
          'message': 'Требуется авторизация',
          'needsAuth': true,
        };
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Ошибка удаления адреса',
        };
      }
    } catch (e) {
      print('❌ Error deleting address: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  static Map<String, dynamic> _convertToServerFormat(
    Map<String, dynamic> data,
  ) {
    final serverData = <String, dynamic>{};

    serverData['title'] = data['title'] ?? '';
    serverData['street'] = data['street'] ?? '';
    serverData['houseNumber'] = data['houseNumber'] ?? data['house'] ?? '';
    serverData['apartmentNumber'] =
        data['apartmentNumber'] ?? data['apartment']?.toString() ?? '';
    serverData['floor'] = data['floor'] != null
        ? int.tryParse(data['floor'].toString()) ?? 0
        : 0;
    serverData['entrance'] = data['entrance']?.toString() ?? '';
    serverData['doorcode'] = data['doorcode'] ?? '';
    serverData['comment'] = data['comment'] ?? '';
    serverData['isPrimary'] = data['isPrimary'] ?? false;

    serverData.removeWhere((key, value) {
      if (value is String) return value.isEmpty;
      return false;
    });

    return serverData;
  }

  static Map<String, dynamic> _convertFromServerFormat(
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
}
