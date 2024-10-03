import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import flutter_svg untuk menggunakan ikon SVG
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:trad/Model/RestAPI/service_kasir.dart';
import 'package:trad/Screen/KasirScreen/kasir_screen.dart'; // Import KasirScreen

class NotaListProduk extends StatefulWidget {
  final String idTransaksi; // ID Transaksi yang diteruskan ke halaman ini
  final int idToko; // Tambahkan ID Toko untuk navigasi ke KasirScreen

  NotaListProduk({Key? key, required this.idTransaksi, required this.idToko})
      : super(key: key);

  @override
  _NotaListProdukState createState() => _NotaListProdukState();
}

class _NotaListProdukState extends State<NotaListProduk> {
  late Future<Map<String, dynamic>> futureDetailNota;
  final ServiceKasir serviceKasir = ServiceKasir(); // Inisialisasi Service
  bool _isExpanded = false; // Variabel untuk mengatur expand/collapse

  double additionalFee = 0.0; // Untuk biaya tambahan
  double additionalVoucher = 0.0; // Untuk voucher tambahan

  @override
  void initState() {
    super.initState();
    // Panggil service untuk mendapatkan detail nota berdasarkan ID transaksi
    futureDetailNota =
        serviceKasir.getDetailNotaBayarListProduk(widget.idTransaksi);
  }

  // Fungsi untuk mendapatkan gambar produk seperti di TinjauPesanan
  ImageProvider<Object> _getImageProvider(dynamic fotoProduk) {
    if (fotoProduk == null || (fotoProduk is List && fotoProduk.isEmpty)) {
      return const AssetImage('assets/img/default_image.png'); // Default image
    } else if (fotoProduk is List) {
      // Jika fotoProduk adalah list, ambil elemen pertama
      final firstFoto =
          fotoProduk[0]['fotoProduk']; // Mengambil base64 dari objek dalam list
      if (firstFoto != null &&
          firstFoto is String &&
          firstFoto.startsWith('/9j/')) {
        // Jika elemen pertama adalah base64, gunakan MemoryImage
        return MemoryImage(base64Decode(firstFoto));
      } else if (firstFoto is String) {
        // Jika elemen pertama adalah URL, gunakan NetworkImage
        return NetworkImage(firstFoto);
      }
    } else if (fotoProduk is String && fotoProduk.startsWith('/9j/')) {
      // Jika fotoProduk adalah string base64, gunakan MemoryImage
      return MemoryImage(base64Decode(fotoProduk));
    } else if (fotoProduk is String) {
      // Jika fotoProduk adalah URL, gunakan NetworkImage
      return NetworkImage(fotoProduk);
    }
    return const AssetImage('assets/img/default_image.png'); // Default image
  }

  void _showQRPopup(BuildContext context, String noNota) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min, // To make dialog wrap content
            children: [
              Text(
                'Kode Pembayaran: $noNota',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF005466),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              PrettyQr(
                data: noNota,
                size: 200,
                roundEdges: true,
                errorCorrectLevel: QrErrorCorrectLevel.M,
              ),
              const SizedBox(height: 24),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                'Tutup',
                style: TextStyle(color: Color(0xFF005466)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gambar latar belakang
          Positioned.fill(
            child: Image.asset(
              'assets/img/bekgron.png', // Gambar latar belakang
              fit: BoxFit.cover,
            ),
          ),
          // Konten utama
          FutureBuilder<Map<String, dynamic>>(
            future: futureDetailNota,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData) {
                return const Center(child: Text('No data available'));
              } else {
                final data = snapshot.data!;
                final totalPembayaran =
                    double.tryParse(data['totalBelanjaTunai'].toString()) ??
                        0.0;
                final totalVoucher =
                    double.tryParse(data['totalBelanjaVoucher'].toString()) ??
                        0.0;

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row untuk menampilkan Nama Toko dan Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            data['namaToko'] ?? '',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 36), // Jarak 36
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Color(
                                  0xFFD9D9D9), // Warna latar belakang status
                              borderRadius:
                                  BorderRadius.circular(8), // Sudut melingkar
                            ),
                            child: Text(
                              data['status'] ?? 'Status tidak tersedia',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF9CA3AF), // Warna teks status
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Detail Transaksi
                      Text(
                        '${data['tanggalPembayaran']} - ${data['jamPembayaran']}',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Merchant: ',
                                  style: TextStyle(
                                    color: Color(
                                        0xFF9CA3AF), // Warna untuk label "Merchant"
                                    fontSize: 14,
                                  ),
                                ),
                                TextSpan(
                                  text: '${data['namaMerchant']}',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14, // Warna untuk data merchant
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                              height:
                                  4), // Tambahkan jarak antara Merchant dan Pembeli
                          RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Pembeli: ',
                                  style: TextStyle(
                                    color: Color(
                                        0xFF9CA3AF), // Warna untuk label "Pembeli"
                                    fontSize: 14,
                                  ),
                                ),
                                TextSpan(
                                  text: '${data['namaPembeli'] ?? '-'}',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14, // Warna untuk data pembeli
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(),
                      // Kode Pembayaran
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Kode Pembayaran:',
                            style: const TextStyle(
                              color: Color(0xFF005466),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      // Data No Nota
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              data['noNota'] ?? '',
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 16),
                            padding: EdgeInsets
                                .zero, // Remove any padding around the icon
                            onPressed: () {
                              // Ambil nomor nota yang ingin disalin
                              String nomorNota = data['noNota'] ?? '';

                              // Salin nomor nota ke clipboard
                              Clipboard.setData(ClipboardData(text: nomorNota))
                                  .then((_) {
                                // Tampilkan pesan atau snackbar untuk memberi tahu pengguna bahwa nomor telah disalin
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Nomor nota berhasil disalin: $nomorNota'),
                                  ),
                                );
                              });
                            },
                          ),
                          const SizedBox(
                            width: 120,
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      const Text(
                        'List Produk',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(
                              0xFF005466), // Ubah warna teks menjadi merah
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          itemCount: data['detailProduk'].length,
                          separatorBuilder: (context, index) => Divider(
                            color: Colors.grey[300],
                            thickness: 1.0,
                          ),
                          itemBuilder: (context, index) {
                            final produk = data['detailProduk'][index];
                            return Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    child: produk['fotoProduk'] != null &&
                                            produk['fotoProduk'].isNotEmpty
                                        ? Image(
                                            image: _getImageProvider(
                                                produk['fotoProduk']),
                                            fit: BoxFit.cover,
                                          )
                                        : const Icon(Icons.image, size: 24),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          produk['namaProduk'] ??
                                              'Unknown Product',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF005466),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            SvgPicture.asset(
                                              'assets/svg/icons/icons-money.svg',
                                              width: 16,
                                              height: 16,
                                              color: const Color(0xFF005466),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Rp ${(double.tryParse(produk['harga'].toString()) ?? 0).toStringAsFixed(0)},-',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF005466),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            SvgPicture.asset(
                                              'assets/svg/icons/icons-voucher.svg',
                                              width: 16,
                                              height: 16,
                                              color: const Color(0xFF005466),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${produk['voucher'] ?? 0}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF005466),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    'x ${produk['jumlah'] ?? 1}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF005466),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const SizedBox(height: 20),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left:
                                                16.0), // Atur padding kiri di sini
                                        child: Row(
                                          children: [
                                            SvgPicture.asset(
                                              'assets/svg/icons/icons-money.svg',
                                              width: 16,
                                              height: 16,
                                              color: const Color(0xFF005466),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Rp ${double.tryParse(produk['totalHarga'].toString())?.toStringAsFixed(0) ?? '0'},-', // Multiply price by quantity
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF005466),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            right:
                                                15.0), // Atur padding kanan di sini
                                        child: Row(
                                          children: [
                                            SvgPicture.asset(
                                              'assets/svg/icons/icons-voucher.svg',
                                              width: 16,
                                              height: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${double.tryParse(produk['totalVoucher'].toString())?.toStringAsFixed(0) ?? '0'},-', // Multiply voucher by quantity
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF005466),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      Divider(color: Colors.grey[300], thickness: 1.0),
                      if (_isExpanded)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Total Pesanan (${data['detailProduk'].length} Produk)',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF7B8794),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          SvgPicture.asset(
                                            'assets/svg/icons/icons-money.svg',
                                            width: 18,
                                            height: 18,
                                            color: Color(0xFF005466),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Rp. ${totalPembayaran.toStringAsFixed(0)},-',
                                            style: const TextStyle(
                                              color: Color(0xFF005466),
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 55),
                                          SvgPicture.asset(
                                            'assets/svg/icons/icons-voucher.svg',
                                            width: 18,
                                            height: 18,
                                            color: Color(0xFF005466),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${totalVoucher.toStringAsFixed(0)}',
                                            style: const TextStyle(
                                              color: Color(0xFF005466),
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Biaya Tambahan',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Open Sans',
                                      color: Color(0xFF9CA3AF), // Warna teks
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    'Rp. ${(data['biayaTambahanTunai'] != null) ? double.tryParse(data['biayaTambahanTunai'].toString())?.toStringAsFixed(0) ?? '0' : '0'}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF005466),
                                    ),
                                  ),
                                  const SizedBox(width: 100),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    child: SvgPicture.asset(
                                      'assets/svg/icons/icons-voucher.svg',
                                      width: 20,
                                      height: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${(data['biayaTambahanVoucher'] != null) ? double.tryParse(data['biayaTambahanVoucher'].toString())?.toStringAsFixed(0) ?? '0' : '0'}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF005466),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      Divider(color: Colors.grey[300], thickness: 1.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Total Pembayaran',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Row(
                                      children: [
                                        SvgPicture.asset(
                                          'assets/svg/icons/icons-money.svg',
                                          width: 18,
                                          height: 18,
                                          color: Color(0xFF005466),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Rp. ${(totalPembayaran + additionalFee).toStringAsFixed(0)},-',
                                          style: const TextStyle(
                                            color: Color(0xFF005466),
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 45),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Row(
                                      children: [
                                        SvgPicture.asset(
                                          'assets/svg/icons/icons-voucher.svg',
                                          width: 18,
                                          height: 18,
                                          color: Color(0xFF005466),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${(totalVoucher + additionalVoucher).toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            color: Color(0xFF005466),
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            IconButton(
                              icon: Icon(
                                _isExpanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                color: Color(0xFF005466),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isExpanded = !_isExpanded;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Column(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                // Ambil data noNota dari snapshot
                                final String noNota = data['noNota'] ?? '';
                                _showQRPopup(context, noNota);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromRGBO(0, 84, 102, 1),
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              icon: const Icon(Icons.qr_code,
                                  color: Colors.white),
                              label: const Text('Tampilkan QR',
                                  style: TextStyle(color: Colors.white)),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        KasirScreen(idToko: widget.idToko),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor:
                                    const Color.fromRGBO(0, 84, 102, 1),
                                side: const BorderSide(
                                    color: Color.fromRGBO(0, 84, 102, 1)),
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Kembali'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
