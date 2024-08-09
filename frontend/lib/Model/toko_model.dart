class TokoModel {
  int id;
  int userId;
  String fotoProfileToko;
  String namaToko;
  String kategoriToko;
  String alamatToko;
  String nomorTeleponToko;
  String emailToko;
  String deskripsiToko;
  DateTime? createdAt;
  DateTime? updatedAt;

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
    this.createdAt,
    this.updatedAt,
  });

  // Factory method to create an instance from JSON
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
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'fotoProfileToko': fotoProfileToko,
      'namaToko': namaToko,
      'kategoriToko': kategoriToko,
      'alamatToko': alamatToko,
      'NomorTeleponToko': nomorTeleponToko,
      'emailToko': emailToko,
      'deskripsiToko': deskripsiToko,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
