import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:katering_ibu_m_flutter/constants/index.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  Future<List<dynamic>> fetchNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token'); 

    if (token == null) {
      throw Exception('Token not found. User is not logged in.');
    }

    final response = await http.get(
      Uri.parse('$localHost/notifications'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['notifications'];
    } else {
      throw Exception('Failed to fetch notifications: ${response.statusCode}');
    }
  }
}