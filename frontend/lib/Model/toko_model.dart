class TokoModel {
  final int id;
  final int userId;
  final String fotoProfileToko;
  final String fotoQrToko;
  final List<String> fotoToko;  // Berubah menjadi List untuk menampung multiple images
  final String namaToko;
  final Map<String, String> kategoriToko;
  final String alamatToko;
  final String nomorTeleponToko;
  final String emailToko;
  final String deskripsiToko;
  final String provinsiToko;
  final String kotaToko;
  final List<JamOperasional> jamOperasional;

  TokoModel({
    required this.id,
    required this.userId,
    required this.fotoProfileToko,
        required this.fotoQrToko,
    required this.fotoToko,
    required this.namaToko,
    required this.kategoriToko,
    required this.alamatToko,
    required this.nomorTeleponToko,
    required this.emailToko,
    required this.deskripsiToko,
    required this.provinsiToko,
    required this.kotaToko,
    required this.jamOperasional,
  });

  factory TokoModel.fromJson(Map<String, dynamic> json) {
    Map<String, String> kategoriMap = {};
    if (json['kategori_toko'] != null && json['kategori_toko'] is List) {
      List kategoriList = json['kategori_toko'];
      for (var kategori in kategoriList) {
        kategoriMap[kategori['id'].toString()] = kategori['kategori'].toString();
      }
    }

    List<JamOperasional> jamOperasionalList = [];
    if (json['jam_operasional'] != null && json['jam_operasional'] is List) {
      jamOperasionalList = (json['jam_operasional'] as List)
          .map((item) => JamOperasional.fromJson(item))
          .toList();
    }

    List<String> fotoTokoList = [];
    if (json['foto_toko'] != null && json['foto_toko'] is List) {
      fotoTokoList = (json['foto_toko'] as List)
          .map((item) => item['fotoToko'].toString())
          .toList();
    }

    return TokoModel(
      id: json['id'],
      userId: json['userId'],
      fotoProfileToko: json['fotoProfileToko'] ?? '',
      fotoQrToko: json['fotoQrToko'] ?? '',
      fotoToko: fotoTokoList,
      namaToko: json['namaToko'] ?? '',
      kategoriToko: kategoriMap,
      alamatToko: json['alamatToko'] ?? '',
      nomorTeleponToko: json['nomorTeleponToko'] ?? '',
      emailToko: json['emailToko'] ?? '',
      deskripsiToko: json['deskripsiToko'] ?? '',
      provinsiToko: json['provinsiToko'] ?? '',
      kotaToko: json['kotaToko'] ?? '',
      jamOperasional: jamOperasionalList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'fotoProfileToko': fotoProfileToko,
      'fotoToko': fotoToko,
      'namaToko': namaToko,
      'kategoriToko': kategoriToko.values.toList(),
      'alamatToko': alamatToko,
      'nomorTeleponToko': nomorTeleponToko,
      'emailToko': emailToko,
      'deskripsiToko': deskripsiToko,
      'provinsiToko': provinsiToko,
      'kotaToko': kotaToko,
      'jamOperasional': jamOperasional.map((item) => item.toJson()).toList(),
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

  factory JamOperasional.fromJson(Map<String, dynamic> json) {
    return JamOperasional(
      hari: json['hari'] ?? '',
      jamBuka: json['jamBuka'] ?? '',
      jamTutup: json['jamTutup'] ?? '',
      statusBuka: json['statusBuka'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hari': hari,
      'jamBuka': jamBuka,
      'jamTutup': jamTutup,
      'statusBuka': statusBuka ? '1' : '0',
    };
  }
}
