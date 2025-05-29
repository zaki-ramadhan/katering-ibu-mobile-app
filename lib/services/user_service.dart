import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/index.dart';

class UserService {
  Logger logger = Logger();
  Future<List<dynamic>> fetchUsers() async {
    final response = await http.get(Uri.parse('$localHost/users'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<void> createUser(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse('$localHost/users'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(userData),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create user');
    }
  }

  Future<void> updateUser(int userId, Map<String, dynamic> userData) async {
    final response = await http.put(
      Uri.parse('$localHost/users/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(userData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update user');
    }
  }

  Future<void> deleteUser(int userId) async {
    final response = await http.delete(Uri.parse('$localHost/users/$userId'));

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
    Uri.parse('$localHost/users/profile'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  logger.i('Response status: ${response.statusCode}');
  logger.i('Response body: ${response.body}'); 

  if (response.statusCode == 200) {
    return json.decode(response.body)['user']; 
  } else {
    throw Exception('Failed to fetch logged-in user data: ${response.statusCode}');
  }
}

  Future<void> updateLoggedInUser(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(
      'token',
    );

    if (token == null) {
      throw Exception('Token not found. User is not logged in.');
    }

    final response = await http.put(
      Uri.parse(
        '$localHost/users/update',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(userData),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to update logged-in user data: ${response.statusCode}',
      );
    }
  }
}
