import 'package:http/http.dart' as http;
import 'package:katering_ibu_m_flutter/constants/index.dart';
import 'dart:convert';
import '../models/menu_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuService {
  static final MenuService _instance = MenuService._internal();
  factory MenuService() => _instance;
  MenuService._internal();

  Future<List<Menu>> getMenus() async {
    try {
      final response = await http.get(Uri.parse('$localHost/menus'));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'] ?? [];
        // Simpan ke cache
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('cached_menus', response.body);
        return data.map((json) => Menu.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load menus: ${response.statusCode}');
      }
    } catch (e) {
      // Jika gagal (misal offline), ambil dari cache
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('cached_menus');
      if (cached != null) {
        final jsonResponse = json.decode(cached);
        final List<dynamic> data = jsonResponse['data'] ?? [];
        return data.map((json) => Menu.fromJson(json)).toList();
      }
      throw Exception('Network error and no cached data: $e');
    }
  }
}
