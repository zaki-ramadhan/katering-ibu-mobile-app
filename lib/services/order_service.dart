import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:katering_ibu_m_flutter/config/index.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderService {
  Logger logger = Logger();

  Future<List<dynamic>> fetchOrderHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token not found. User is not logged in.');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/history'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        logger.i('Order history response: $data');
        return data['orders'] ?? [];
      } else {
        throw Exception(
          'Failed to fetch order history: ${response.statusCode}',
        );
      }
    } catch (e) {
      // Cache fallback
      final cached = prefs.getString('cached_orders');
      if (cached != null) {
        final data = json.decode(cached);
        return data['orders'] ?? [];
      }
      throw Exception('Network error and no cached data: $e');
    }
  }
}
