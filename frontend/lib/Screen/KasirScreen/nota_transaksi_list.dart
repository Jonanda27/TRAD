import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import flutter_svg untuk menggunakan ikon SVG
import 'package:trad/Model/RestAPI/service_kasir.dart';
import 'package:trad/Screen/KasirScreen/kasir_screen.dart'; // Import KasirScreen

class NotaTransaksi extends StatefulWidget {
  final String idTransaksi; // ID Transaksi yang diteruskan ke halaman ini
  final int idToko; // Corrected to use idToko

  NotaTransaksi({Key? key, required this.idTransaksi,required this.idToko}) : super(key: key);

  @override
  _NotaTransaksiState createState() => _NotaTransaksiState();
}

class _NotaTransaksiState extends State<NotaTransaksi> {
  late Future<Map<String, dynamic>> futureDetailNota;
  final ServiceKasir serviceKasir = ServiceKasir(); // Inisialisasi Service
  bool _isExpanded = false; // Variabel untuk mengatur expand/collapse

  double additionalFee = 0.0; // Untuk biaya tambahan
  double additionalVoucher = 0.0; // Untuk voucher tambahan

  @override
  void initState() {
    super.initState();
    // Panggil service untuk mendapatkan detail nota berdasarkan ID transaksi
    futureDetailNota = serviceKasir.getDetailNotaBayarListProduk(widget.idTransaksi);
  }

  // Fungsi untuk mendapatkan gambar produk seperti di TinjauPesanan
  ImageProvider<Object> _getImageProvider(dynamic fotoProduk) {
    if (fotoProduk == null || (fotoProduk is List && fotoProduk.isEmpty)) {
      return const AssetImage('assets/img/default_image.png'); // Default image
    } else if (fotoProduk is List) {
      final firstFoto = fotoProduk[0]['fotoProduk']; // Mengambil base64 dari objek dalam list
      if (firstFoto != null && firstFoto is String && firstFoto.startsWith('/9j/')) {
        return MemoryImage(base64Decode(firstFoto));
      } else if (firstFoto is String) {
        return NetworkImage(firstFoto);
      }
    } else if (fotoProduk is String && fotoProduk.startsWith('/9j/')) {
      return MemoryImage(base64Decode(fotoProduk));
    } else if (fotoProduk is String) {
      return NetworkImage(fotoProduk);
    }
    return const AssetImage('assets/img/default_image.png');
  }

  void _showQRPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          content: FutureBuilder<Map<String, dynamic>>(
            future: serviceKasir.getTransaksiByToko(widget.idToko.toString()),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData ||
                  snapshot.data!['fotoQrToko'] == null) {
                return const Center(child: Text('QR Toko tidak tersedia'));
              } else {
                final data = snapshot.data!;
                final String? base64Image = data['fotoQrToko'];

                Uint8List? qrImageBytes;
                if (base64Image != null && base64Image.isNotEmpty) {
                  qrImageBytes = base64Decode(base64Image);
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      data['namaToko'] ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF005466),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    if (qrImageBytes != null)
                      Image.memory(
                        qrImageBytes,
                        width: 220,
                        height: 220,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.image_not_supported,
                            size: 100,
                            color: Colors.grey,
                          );
                        },
                      )
                    else
                      const Center(child: Text('QR Toko tidak tersedia')),
                    const SizedBox(height: 24),
                  ],
                );
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
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
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(0, 84, 102, 1),
        title: const Text('Detail Transaksi', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/img/bekgron.png',
              fit: BoxFit.cover,
            ),
          ),
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
                final totalPembayaran = double.tryParse(data['totalBelanjaTunai'].toString()) ?? 0.0;
                final totalVoucher = double.tryParse(data['totalBelanjaVoucher'].toString()) ?? 0.0;

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                          const SizedBox(width: 36),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Color(0xFFFFF9DA),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              data['status'] ?? 'Status tidak tersedia',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF9900),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${data['tanggalPembayaran']} - ${data['jamPembayaran'].substring(0, 5)}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Merchant: ${data['namaMerchant']}'),
                          Text('Pembeli: ${data['namaPembeli'] ?? '-'}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(),
                      // Kode Pembayaran and Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Kode Pembayaran:',
                                style: TextStyle(
                                  color: Color(0xFF005466),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    data['noNota'] ?? '',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.copy, size: 16),
                                    onPressed: () {
                                      // Logic to copy the payment code
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 30, // Adjusted height for the button
                            child: ElevatedButton(
                              onPressed: () {
                                _showQRPopup(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: BorderSide(color: Color(0xFF005466)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 8), // Adjusted padding
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.qr_code, color: Color(0xFF005466), size: 16),
                                  SizedBox(width: 2),
                                  Text(
                                    'Tampilkan QR',
                                    style: TextStyle(
                                      color: Color(0xFF005466),
                                      fontSize: 12, // Adjusted font size
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('List Produk', style: TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(
                        child: ListView.separated(
                          itemCount: data['detailProduk'].length,
                          separatorBuilder: (context, index) => Divider(
                            color: Colors.grey[300],
                            thickness: 1.0,
                          ),
                          itemBuilder: (context, index) {
                            final produk = data['detailProduk'][index];
                            return ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  color: Colors.grey[200],
                                  child: produk['fotoProduk'] != null && produk['fotoProduk'].isNotEmpty
                                      ? Image(
                                          image: _getImageProvider(produk['fotoProduk']),
                                          fit: BoxFit.cover,
                                        )
                                      : const Icon(Icons.image_not_supported),
                                ),
                              ),
                              title: Text(produk['namaProduk']),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Rp ${produk['harga']},-'),
                                  Text('Voucher: ${produk['voucher'] ?? '0'}'),
                                  Text('Jumlah: ${produk['jumlah']}'),
                                ],
                              ),
                              trailing: Text('Rp ${produk['totalHarga']},-'),
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                            '/svg/icons/icons-money.svg',
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Biaya Tambahan',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Open Sans',
                                      color: Color(0xFF9CA3AF),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Text(
                                    'Rp.',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF005466),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      decoration: InputDecoration(
                                        hintText: '0',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          additionalFee = double.tryParse(value) ?? 0.0;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 21),
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
                                  Expanded(
                                    child: TextField(
                                      decoration: InputDecoration(
                                        hintText: '0',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          additionalVoucher = double.tryParse(value) ?? 0.0;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      Divider(color: Colors.grey[300], thickness: 1.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Total Pembayaran', style: TextStyle(fontWeight: FontWeight.bold)),
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
                                    const Text('', style: TextStyle(fontWeight: FontWeight.bold)),
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
                                _isExpanded ? Icons.expand_less : Icons.expand_more,
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
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                // Logika untuk membatalkan transaksi
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: BorderSide(color: Colors.red),
                                minimumSize: Size(150, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: const Text(
                                'Batalkan',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Logika untuk menerima transaksi
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFE0E0E0),
                                minimumSize: Size(150, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: const Text(
                                'Terima',
                                style: TextStyle(
                                  color: Color(0xFF9E9E9E),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
