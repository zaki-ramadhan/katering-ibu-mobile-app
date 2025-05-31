import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:katering_ibu_m_flutter/config/index.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  Future<List<dynamic>> fetchNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token not found. User is not logged in.');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        prefs.setString('cached_notifications', response.body);
        return data['notifications'] ?? [];
      } else {
        throw Exception(
          'Failed to fetch notifications: ${response.statusCode}',
        );
      }
    } catch (e) {
      final cached = prefs.getString('cached_notifications');
      if (cached != null) {
        final data = json.decode(cached);
        return data['notifications'] ?? [];
      }
      rethrow;
    }
  }
}
