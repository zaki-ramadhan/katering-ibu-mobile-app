import 'package:intl/intl.dart';

class Menu {
  final int id;
  final String namaMenu;
  final String deskripsi;
  final double harga;
  final String foto;
  final int terjual;
  final String? kategori;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  static final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  Menu({
    required this.id,
    required this.namaMenu,
    required this.deskripsi,
    required this.harga,
    required this.foto,
    this.terjual = 0,
    this.kategori,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      id: json['id'] ?? 0,
      namaMenu: json['nama_menu'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      harga: double.tryParse(json['harga'].toString()) ?? 0.0,
      foto: json['foto'] ?? '',
      terjual: json['terjual'] ?? 0,
      kategori: json['kategori'],
      status: json['status'],
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.tryParse(json['updated_at'])
              : null,
    );
  }

  String get formattedHarga => currencyFormatter.format(harga);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_menu': namaMenu,
      'deskripsi': deskripsi,
      'harga': harga,
      'foto': foto,
      'terjual': terjual,
      'kategori': kategori,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
