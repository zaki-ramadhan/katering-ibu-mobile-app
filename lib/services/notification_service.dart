import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:katering_ibu_m_flutter/config/index.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

class NotificationService {
  final Logger _logger = Logger();

  Future<List<dynamic>> fetchNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        _logger.w('No auth token found');
        return [];
      }

      final response = await http.get(
        Uri.parse('$baseUrl/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'] ?? [];
        }
      }

      return [];
    } catch (e) {
      _logger.e('Error fetching notifications: $e');
      return [];
    }
  }

  Future<void> createNotification({
    required int userId,
    required String title,
    required String message,
    String? type,
    int? orderId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token not found. User is not logged in.');
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notifications/create'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
          'order_id': orderId,
          'title': title,
          'message': message,
          'type': type ?? 'general',
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to create notification');
      }
    } catch (e) {
      throw Exception('Error creating notification: $e');
    }
  }
}
