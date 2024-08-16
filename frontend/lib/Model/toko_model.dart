class TokoModel {
  final int id;
  final int userId;
  final String fotoProfileToko; // Changed to nullable to match `null` in JSON
  final String namaToko;
  final String kategoriToko;
  final String alamatToko;
  final String nomorTeleponToko;
  final String emailToko;
  final String deskripsiToko;
  final String provinsiToko; // Added to match JSON
  final String kotaToko; // Added to match JSON
  

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
    required this.provinsiToko,
    required this.kotaToko,
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
      provinsiToko: json['provinsiToko'],
      kotaToko: json['kotaToko'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'fotoProfileToko': fotoProfileToko,
      'namaToko': namaToko,
      'kategoriToko': kategoriToko,
      'alamatToko': alamatToko,
      'nomorTeleponToko': nomorTeleponToko,
      'emailToko': emailToko,
      'deskripsiToko': deskripsiToko,
      'provinsiToko': provinsiToko,
      'kotaToko': kotaToko,
      // 'jamOperasional': jamOperasional.map((e) => e.toJson()).toList(),
      // 'fotoToko': fotoToko,
    };
  }
}

class JamOperasional {
  final String hari;
  final String jamBuka;
  final String jamTutup;
  final bool statusBuka;

  JamOperasional({
    required this.hari,
    required this.jamBuka,
    required this.jamTutup,
    required this.statusBuka,
  });

  Map<String, dynamic> toJson() {
    return {
      'hari': hari,
      'jamBuka': jamBuka,
      'jamTutup': jamTutup,
      'statusBuka': statusBuka,
    };
  }
}
