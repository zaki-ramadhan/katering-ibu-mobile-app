import 'package:intl/intl.dart'; 

class Menu {
  final int id;
  final String foto;
  final String namaMenu;
  final String deskripsi;
  final double harga; 
  final int terjual;

  static final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  Menu({
    required this.id,
    required this.foto,
    required this.namaMenu,
    required this.deskripsi,
    required this.harga,
    required this.terjual,
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      id: json['id'] ?? 0,
      foto: json['foto'] ?? '',
      namaMenu: json['nama'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      harga: json['harga'] != null 
          ? double.tryParse(json['harga'].toString()) ?? 0.0 
          : 0.0,
      terjual: json['terjual'] ?? 0,
    );
  }

  String get formattedHarga => currencyFormatter.format(harga);


  Map<String, dynamic> toJson() => {
    'id': id,
    'image_url': foto,
    'nama_menu': namaMenu,
    'deskripsi': deskripsi,
    'harga': harga,
    'terjual': terjual,
  };

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image': foto,
      'name': namaMenu,
      'description': deskripsi,
      'price': harga,
      'sold': terjual,
    };
  }

  Menu copyWith({
    int? id,
    String? foto,
    String? namaMenu,
    String? deskripsi,
    double? harga,
    int? terjual,
  }) {
    return Menu(
      id: id ?? this.id,
      foto: foto ?? this.foto,
      namaMenu: namaMenu ?? this.namaMenu,
      deskripsi: deskripsi ?? this.deskripsi,
      harga: harga ?? this.harga,
      terjual: terjual ?? this.terjual,
    );
  }
}