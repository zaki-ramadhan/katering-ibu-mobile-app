import 'package:katering_ibu_m_flutter/models/user_model.dart';

class Ulasan {
  final int id;
  final User user;
  final String pesan;
  final String waktu;
  final String createdAt;

  Ulasan({
    required this.id,
    required this.user,
    required this.pesan,
    required this.waktu,
    required this.createdAt,
  });

  factory Ulasan.fromJson(Map<String, dynamic> json) {
    return Ulasan(
      id: json['id'],
      user: User.fromJson(json['user']),
      pesan: json['pesan'],
      waktu: json['waktu'],
      createdAt: json['created_at'],
    );
  }
}