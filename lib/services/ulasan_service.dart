import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:katering_ibu_m_flutter/config/index.dart';
import '../models/ulasan_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UlasanService {
  Future<List<Ulasan>> getUlasan() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final response = await http.get(Uri.parse('$baseUrl/ulasan'));

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body)['data'];
        prefs.setString('cached_ulasan', response.body);
        return jsonResponse.map((data) => Ulasan.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load ulasan');
      }
    } catch (e) {
      final cached = prefs.getString('cached_ulasan');
      if (cached != null) {
        List jsonResponse = json.decode(cached)['data'];
        return jsonResponse.map((data) => Ulasan.fromJson(data)).toList();
      }
      throw Exception('Tidak ada data ulasan (offline & belum pernah online)');
    }
  }
}
