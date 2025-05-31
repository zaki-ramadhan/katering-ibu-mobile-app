class User {
  final int id;
  final String nama;
  // final String email;
  final String? fotoProfil;

  User({
    required this.id,
    required this.nama,
    // required this.email,
    this.fotoProfil,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nama: json['nama'],
      // email: json['email'],
      fotoProfil: json['foto_profil'],
    );
  }
}