class User {
  final int id;
  final String nama;
  final String? email;
  final String? phone;
  final String? fotoProfil;

  User({
    required this.id,
    required this.nama,
    this.email,
    this.phone,
    this.fotoProfil,
  });

  String get name => nama;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? json['name'] ?? 'User',
      email: json['email'],
      phone: json['phone'] ?? json['notelp'] ?? json['no_hp'],
      fotoProfil: json['foto_profil'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'phone': phone,
      'foto_profil': fotoProfil,
    };
  }
}
