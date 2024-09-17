class Produk {
  final int id;
  final int idToko;
  final String namaProduk;
  final List<String> fotoProduk;
  final List<int> kategori;
  final double harga;
  final double rating;
  final String? voucher;
  final int terjual;
 String statusProduk; // Mengubah tipe menjadi String
  final String sortBy;
  final String sortOrder;
  final List<String> hashtag;
  final double bagiHasil; // Field bagiHasil
  final String kodeProduk; // Field kodeProduk
  final String deskripsiProduk; // Field deskripsiProduk

  Produk({
    required this.id,
    required this.idToko,
    required this.namaProduk,
    required this.fotoProduk,
    required this.kategori,
    required this.harga,
    required this.rating,
    this.voucher,
    required this.terjual,
    required this.statusProduk,
    required this.sortBy,
    required this.sortOrder,
    required this.hashtag,
    required this.bagiHasil, // Menambahkan bagiHasil ke constructor
    required this.kodeProduk, // Menambahkan kodeProduk ke constructor
    required this.deskripsiProduk, // Menambahkan deskripsiProduk ke constructor
  });

  factory Produk.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      } else if (value is num) {
        return value.toDouble();
      }
      return 0.0;
    }

    return Produk(
      id: json['id'] ?? 0,
      idToko: json['idToko'] ?? 0,
      namaProduk: json['namaProduk'],
      fotoProduk: List<String>.from(json['fotoProduk'] ?? []),
      kategori: List<int>.from(json['kategori'] ?? []),
      harga: parseDouble(json['harga']),
      rating: parseDouble(json['rating']),
      voucher: json['voucher'],
      terjual: (json['terjual'] is String)
          ? int.tryParse(json['terjual']) ?? 0
          : json['terjual'] ?? 0,
       statusProduk: json['status'] ?? 'nonaktif',
      sortBy: json['sortBy'] ?? 'namaProduk',
      sortOrder: json['sortOrder'] ?? 'asc',
      hashtag: List<String>.from(json['hashtag'] ?? []),
      bagiHasil: parseDouble(json['bagiHasil']), // Parsing bagiHasil dari JSON
      kodeProduk:
          json['kodeProduk'] ?? '', // Parsing kodeProduk dari JSON
      deskripsiProduk:
          json['deskripsiProduk'] ?? '', // Parsing deskripsiProduk dari JSON
    );
  }

  // Jika diperlukan, Anda bisa menambahkan metode toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idToko': idToko,
      'namaProduk': namaProduk,
      'fotoProduk': fotoProduk,
      'kodeProduk': kodeProduk,
      'kategori': kategori,
      'harga': harga,
      'rating': rating,
      'voucher': voucher,
      'terjual': terjual,
       'status': statusProduk == 'aktif' ? true : false,
      'sortBy': sortBy,
      'sortOrder': sortOrder,
      'hashtag': hashtag,
    };
  }
}
