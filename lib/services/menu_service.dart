import 'package:http/http.dart' as http;
import 'package:katering_ibu_m_flutter/constants/index.dart';
import 'dart:convert';
import '../models/menu_model.dart';

class MenuService {
  static final MenuService _instance = MenuService._internal();
  factory MenuService() => _instance;
  MenuService._internal();

  Future<List<Menu>> getMenus() async {
    try {
      final response = await http.get(Uri.parse('$localHost/menus'));

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        List<dynamic> data = jsonResponse['data'];

        return data.map((json) => Menu.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load menus: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
