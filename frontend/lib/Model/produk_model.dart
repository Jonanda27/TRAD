class Produk {
  final int id;
  final int idToko;
  final String name;
  final List<String> fotoProduk;
  final List<String> kategori;
  final double harga;
  final double rating;
  final String? voucher;
  final int terjual;
  final bool statusProduk;
  final String sortBy;
  final String sortOrder;
  final List<String> hashtag;  // Menambahkan field hashtag

  Produk({
    required this.id,
    required this.idToko,
    required this.name,
    required this.fotoProduk,
    required this.kategori,
    required this.harga,
    required this.rating,
    this.voucher,
    required this.terjual,
    required this.statusProduk,
    required this.sortBy,
    required this.sortOrder,
    required this.hashtag,  // Menambahkan hashtag ke constructor
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
      name: json['namaProduk'] ?? 'Unknown',
      fotoProduk: List<String>.from(json['fotoProduk'] ?? []),
      kategori: List<String>.from(json['kategori'] ?? []),
      harga: parseDouble(json['harga']),
      rating: parseDouble(json['rating']),
      voucher: json['voucher'],
      terjual: (json['terjual'] is String) ? int.tryParse(json['terjual']) ?? 0 : json['terjual'] ?? 0,
      statusProduk: json['statusProduk'] == 'Available', // Assuming 'Available' indicates active
      sortBy: json['sortBy'] ?? 'name',
      sortOrder: json['sortOrder'] ?? 'asc',
      hashtag: List<String>.from(json['hashtag'] ?? []),  // Parsing hashtag dari JSON
    );
  }

  // Jika diperlukan, Anda bisa menambahkan metode toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idToko': idToko,
      'namaProduk': name,
      'fotoProduk': fotoProduk,
      'kategori': kategori,
      'harga': harga,
      'rating': rating,
      'voucher': voucher,
      'terjual': terjual,
      'statusProduk': statusProduk ? 'Available' : 'Unavailable',
      'sortBy': sortBy,
      'sortOrder': sortOrder,
      'hashtag': hashtag,
    };
  }
}