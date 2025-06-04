import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:katering_ibu_m_flutter/config/index.dart';
import '../models/ulasan_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

class UlasanService {
  final Logger logger = Logger();

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<Ulasan>> getUlasan() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/ulasan'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          List jsonResponse = data['data'];
          prefs.setString('cached_ulasan', response.body);
          return jsonResponse.map((data) => Ulasan.fromJson(data)).toList();
        } else {
          throw Exception('Failed to load ulasan');
        }
      } else {
        throw Exception('Failed to load ulasan');
      }
    } catch (e) {
      final cached = prefs.getString('cached_ulasan');
      if (cached != null) {
        final data = json.decode(cached);
        List jsonResponse = data['data'];
        return jsonResponse.map((data) => Ulasan.fromJson(data)).toList();
      }
      throw Exception('Tidak ada data ulasan (offline & belum pernah online)');
    }
  }

  Future<Map<String, dynamic>> submitUlasan({
    required int orderId,
    required String Ulasan,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/ulasan'),
        headers: headers,
        body: jsonEncode({'order_id': orderId, 'Ulasan': Ulasan}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success']) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengirim ulasan',
        };
      }
    } catch (e) {
      logger.e('Submit ulasan error: $e');
      return {'success': false, 'message': 'Terjadi kesalahan koneksi: $e'};
    }
  }

  Future<Map<String, dynamic>> checkUserReviewForOrder(int orderId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/ulasan/check-order/$orderId'),
        headers: headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return {
          'success': true,
          'has_reviewed': data['has_reviewed'],
          'review_data': data['review_data'],
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'has_reviewed': false,
          'message': data['message'] ?? 'Gagal mengecek ulasan',
        };
      }
    } catch (e) {
      logger.e('Check review error: $e');
      return {
        'success': false,
        'has_reviewed': false,
        'message': 'Terjadi kesalahan koneksi: $e',
      };
    }
  }
}
