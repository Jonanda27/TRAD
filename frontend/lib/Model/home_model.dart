class HomeData {
  final int id;
  final String fotoProfil;
  final String nama;
  final String status;
  final String expDate;
  final int tradVoucher;
  final int tradPoint;
  final int jumlahToko;
  final List<Toko> tokos;

  HomeData({
    required this.id,
    required this.fotoProfil,
    required this.nama,
    required this.status,
    required this.expDate,
    required this.tradVoucher,
    required this.tradPoint,
    required this.jumlahToko,
    required this.tokos,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) {
    var list = json['tokos'] as List;
    List<Toko> tokoList = list.map((i) => Toko.fromJson(i)).toList();

    return HomeData(
      id: json['id'],
      fotoProfil: json['fotoProfil'],
      nama: json['nama'],
      status: json['status'],
      expDate: json['expDate'],
      tradVoucher: json['tradVoucher'],
      tradPoint: json['tradPoint'],
      jumlahToko: json['jumlahToko'],
      tokos: tokoList,
    );
  }
}

class Toko {
  final String nama;
  final String gambar;

  Toko({required this.nama, required this.gambar});

  factory Toko.fromJson(Map<String, dynamic> json) {
    return Toko(
      nama: json['nama'],
      gambar: json['gambar'],
    );
  }
}
