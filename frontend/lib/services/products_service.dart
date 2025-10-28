import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_service.dart';

class ProductsService {
  static const String baseUrl = 'http://localhost:3000/api/products';

  static Future<Map<String, String>> _getHeaders({
    bool needsAuth = false,
  }) async {
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (needsAuth) {
      final token = await TokenService.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  static Future<Map<String, dynamic>> getProducts({
    int? page,
    int? limit,
    String? category,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      print('🔄 Getting products from API...');

      final params = <String, String>{};
      if (page != null) params['page'] = page.toString();
      if (limit != null) params['limit'] = limit.toString();
      if (category != null) params['category'] = category;
      if (sortBy != null) params['sortBy'] = sortBy;
      if (sortOrder != null) params['sortOrder'] = sortOrder;

      final uri = Uri.parse('$baseUrl').replace(queryParameters: params);
      print('📡 URL: $uri');

      final response = await http.get(uri);
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        dynamic productsData = data['data'];

        if (productsData is Map<String, dynamic>) {
          productsData =
              productsData['products'] ?? productsData['items'] ?? productsData;
        }

        if (productsData is! List) {
          productsData = [productsData];
        }

        print('✅ Products loaded successfully: ${productsData.length} items');
        return {'success': true, 'data': productsData};
      } else {
        print('❌ Error loading products: ${data['message']}');
        return {
          'success': false,
          'message': data['message'] ?? 'Ошибка получения продуктов',
        };
      }
    } catch (e) {
      print('❌ Network error: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  static Future<Map<String, dynamic>> getCategories() async {
    try {
      print('🔄 Getting categories from API...');

      final uri = Uri.parse('$baseUrl/categories');
      print('📡 URL: $uri');

      final response = await http.get(uri);
      print('📥 Response status: ${response.statusCode}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        dynamic categoriesData = data['data'];

        print('🔍 Categories data structure:');
        print('   Type: ${categoriesData.runtimeType}');
        if (categoriesData is List) {
          print('   Count: ${categoriesData.length}');
          if (categoriesData.isNotEmpty) {
            print('   First item: ${categoriesData.first}');
          }
        }

        if (categoriesData is Map<String, dynamic>) {
          categoriesData =
              categoriesData['categories'] ??
              categoriesData['items'] ??
              categoriesData;
        }

        if (categoriesData is! List) {
          categoriesData = [categoriesData];
        }

        print('✅ Categories loaded: ${categoriesData.length} items');
        return {'success': true, 'data': categoriesData};
      } else {
        print('❌ Error loading categories: ${data['message']}');
        return {
          'success': false,
          'message': data['message'] ?? 'Ошибка получения категорий',
        };
      }
    } catch (e) {
      print('❌ Network error: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  static Future<Map<String, dynamic>> searchProducts(String query) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/search?q=$query'));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        dynamic productsData = data['data'];

        if (productsData is Map<String, dynamic>) {
          productsData =
              productsData['products'] ?? productsData['items'] ?? productsData;
        }

        if (productsData is! List) {
          productsData = [productsData];
        }

        return {'success': true, 'data': productsData};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Ошибка поиска продуктов',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  static Future<Map<String, dynamic>> getPopularProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/popular'));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        dynamic productsData = data['data'];

        if (productsData is Map<String, dynamic>) {
          productsData =
              productsData['products'] ?? productsData['items'] ?? productsData;
        }

        if (productsData is! List) {
          productsData = [productsData];
        }

        return {'success': true, 'data': productsData};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Ошибка получения популярных продуктов',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  static Future<Map<String, dynamic>> getProductById(String productId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$productId'));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Ошибка получения продукта',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateProduct(
    String productId,
    Map<String, dynamic> productData,
  ) async {
    try {
      final headers = await _getHeaders(needsAuth: true);
      final response = await http.put(
        Uri.parse('$baseUrl/$productId'),
        headers: headers,
        body: jsonEncode(productData),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Ошибка обновления продукта',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }
}
