class User {
  final int id;
  final String nama;
  final String? fotoProfil;

  User({
    required this.id,
    required this.nama,
    this.fotoProfil,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nama: json['nama'],
      fotoProfil: json['foto_profil'],
    );
  }
}