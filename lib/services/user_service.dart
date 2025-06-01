import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:katering_ibu_m_flutter/config/index.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  Logger logger = Logger();
  Future<List<dynamic>> fetchUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/users'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<void> createUser(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(userData),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create user');
    }
  }

  Future<void> updateUser(int userId, Map<String, dynamic> userData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(userData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update user');
    }
  }

  Future<void> deleteUser(int userId) async {
    final response = await http.delete(Uri.parse('$baseUrl/users/$userId'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete user');
    }
  }

  Future<Map<String, dynamic>> fetchLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      logger.i('Token not found in SharedPreferences');
      throw Exception('Token not found. User is not logged in.');
    }

    logger.i('Token fetched: $token');

    final response = await http.get(
      Uri.parse('$baseUrl/users/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    logger.i('Response status: ${response.statusCode}');
    logger.i('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final user = json.decode(response.body)['user'];
      // Simpan ke cache
      prefs.setString('cached_logged_in_user', json.encode(user));
      return user;
    } else {
      // Jika gagal, ambil dari cache
      final cached = prefs.getString('cached_logged_in_user');
      if (cached != null) {
        return json.decode(cached);
      }
      throw Exception(
        'Failed to fetch logged-in user data: ${response.statusCode}',
      );
    }
  }

  Future<void> updateLoggedInUser(
    Map<String, dynamic> userData, {
    File? profileImage,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token not found. User is not logged in.');
    }

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/users/update'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      userData.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      if (profileImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('foto_profile', profileImage.path),
        );
      }

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(responseData);
        if (data['status'] == 'success') {
          return;
        } else {
          throw Exception(data['message'] ?? 'Failed to update user');
        }
      } else {
        final errorData = json.decode(responseData);
        throw Exception(errorData['message'] ?? 'Failed to update user');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
