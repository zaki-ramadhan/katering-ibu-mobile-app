import 'package:katering_ibu_m_flutter/models/menu_model.dart';

class Keranjang {
  final int id;
  final int userId;
  final double totalHarga;
  final String status;
  final List<KeranjangItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  Keranjang({
    required this.id,
    required this.userId,
    required this.totalHarga,
    required this.status,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Keranjang.fromJson(Map<String, dynamic> json) {
    return Keranjang(
      id: json['id'],
      userId: json['user_id'],
      totalHarga: double.parse(json['total_harga'].toString()),
      status: json['status'],
      items:
          (json['items'] as List? ?? [])
              .map((item) => KeranjangItem.fromJson(item))
              .toList(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'total_harga': totalHarga,
      'status': status,
      'items': items.map((item) => item.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class KeranjangItem {
  final int id;
  final int keranjangId;
  final int menuId;
  final int jumlah;
  final double harga;
  final double totalHargaItem;
  final Menu menu;
  final DateTime createdAt;
  final DateTime updatedAt;

  KeranjangItem({
    required this.id,
    required this.keranjangId,
    required this.menuId,
    required this.jumlah,
    required this.harga,
    required this.totalHargaItem,
    required this.menu,
    required this.createdAt,
    required this.updatedAt,
  });

  factory KeranjangItem.fromJson(Map<String, dynamic> json) {
    return KeranjangItem(
      id: json['id'],
      keranjangId: json['keranjang_id'],
      menuId: json['menu_id'],
      jumlah: json['jumlah'],
      harga: double.parse(json['harga'].toString()),
      totalHargaItem: double.parse(json['total_harga_item'].toString()),
      menu: Menu.fromJson(json['menu']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'keranjang_id': keranjangId,
      'menu_id': menuId,
      'jumlah': jumlah,
      'harga': harga,
      'total_harga_item': totalHargaItem,
      'menu': menu.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
