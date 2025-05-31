import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:katering_ibu_m_flutter/config/index.dart';

class AuthService {
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
    required bool rememberMe,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'username': username, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setInt('user_id', data['user']['id']);
        await prefs.setString('user_name', data['user']['name']);
        await prefs.setString('user_role', data['user']['role']);
        await prefs.setBool('remember_me', rememberMe);

        if (rememberMe) {
          await prefs.setString('saved_username', username);
          await prefs.setString('saved_password', password);
        } else {
          await prefs.remove('saved_username');
          await prefs.remove('saved_password');
        }

        return {
          'success': true,
          'user': data['user'],
          'message': 'Login berhasil',
        };
      } else {
        return {'success': false, 'message': data['message'] ?? 'Login gagal'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi'};
    }
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('last_password', password);

        return {'success': true, 'message': 'Pendaftaran berhasil!'};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Pendaftaran gagal. Terjadi kesalahan.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Pendaftaran gagal. Periksa koneksi internet Anda.',
      };
    }
  }

  static Future<bool> checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userId = prefs.getInt('user_id');
      final rememberMe = prefs.getBool('remember_me') ?? false;

      if (token != null && userId != null && rememberMe) {
        return true;
      } else if (!rememberMe) {
        await logout();
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, String>> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool('remember_me') ?? false;

    if (rememberMe) {
      return {
        'username': prefs.getString('saved_username') ?? '',
        'password': prefs.getString('saved_password') ?? '',
        'remember_me': 'true',
      };
    }

    return {'username': '', 'password': '', 'remember_me': 'false'};
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_role');
    await prefs.remove('saved_username');
    await prefs.remove('saved_password');
    await prefs.setBool('remember_me', false);
  }
}
