import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ulasan_model.dart';
import '../constants/index.dart';

class UlasanService {
  Future<List<Ulasan>> getUlasan() async {
    final response = await http.get(Uri.parse('$localHost/ulasan'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body)['data'];
      return jsonResponse.map((data) => Ulasan.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load ulasan');
    }
  }
}
