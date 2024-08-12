class TokoModel {
  final int id;
  final int userId;
  final String fotoProfileToko;
  final String namaToko;
  final String kategoriToko;
  final String alamatToko;
  final String nomorTeleponToko;
  final String emailToko;
  final String deskripsiToko;

  TokoModel({
    required this.id,
    required this.userId,
    required this.fotoProfileToko,
    required this.namaToko,
    required this.kategoriToko,
    required this.alamatToko,
    required this.nomorTeleponToko,
    required this.emailToko,
    required this.deskripsiToko,
  });

  factory TokoModel.fromJson(Map<String, dynamic> json) {
    return TokoModel(
      id: json['id'],
      userId: json['userId'],
      fotoProfileToko: json['fotoProfileToko'],
      namaToko: json['namaToko'],
      kategoriToko: json['kategoriToko'],
      alamatToko: json['alamatToko'],
      nomorTeleponToko: json['NomorTeleponToko'],
      emailToko: json['emailToko'],
      deskripsiToko: json['deskripsiToko'],
    );
  }
}
