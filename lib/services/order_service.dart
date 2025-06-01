import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:katering_ibu_m_flutter/config/index.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderService {
  Logger logger = Logger();

  Future<Map<String, dynamic>> createOrder({
    required String pickupMethod,
    required String paymentMethod,
    String? deliveryAddress,
    String? transferMethod,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return {
          'success': false,
          'message': 'Token not found. User is not logged in.',
        };
      }

      Map<String, dynamic> requestBody = {
        'pickup_method': pickupMethod,
        'payment_method': paymentMethod,
      };

      if (deliveryAddress != null) {
        requestBody['delivery_address'] = deliveryAddress;
      }

      if (transferMethod != null) {
        requestBody['transfer_method'] = transferMethod;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      logger.i('Response Status: ${response.statusCode}');
      logger.i('Response Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal membuat pesanan',
        };
      }
    } catch (e) {
      logger.e('Order Service Error: $e');
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

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
          'Accept': 'application/json',
        },
      );

      logger.i('Order history response status: ${response.statusCode}');
      logger.i('Order history response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      } else {
        throw Exception(
          'Failed to fetch order history: ${response.statusCode}',
        );
      }
    } catch (e) {
      logger.e('Fetch order history error: $e');
      final cached = prefs.getString('cached_orders');
      if (cached != null) {
        final data = json.decode(cached);
        return data['data'] ?? [];
      }
      throw Exception('Network error and no cached data: $e');
    }
  }

  Future<void> deleteOrder(int orderId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token not found. User is not logged in.');
    }

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/orders/$orderId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      logger.i('Delete order response: ${response.statusCode}');
      logger.i('Delete order body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] != 'success') {
          throw Exception(responseData['message'] ?? 'Failed to delete order');
        }
      } else {
        if (response.body.startsWith('<!DOCTYPE')) {
          throw Exception('Server error - endpoint not found');
        }

        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ??
              'Failed to delete order: ${response.statusCode}',
        );
      }
    } catch (e) {
      logger.e('Delete order error: $e');
      if (e.toString().contains('FormatException')) {
        throw Exception('Server sedang bermasalah, coba lagi nanti');
      }
      throw Exception(e.toString());
    }
  }
}
