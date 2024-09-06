import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:trad/Model/RestAPI/service_kasir.dart';
import 'package:trad/kasir_screen.dart'; // Import KasirScreen

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

  @override
  void initState() {
    super.initState();
    // Panggil service untuk mendapatkan detail nota berdasarkan ID transaksi
    futureDetailNota =
        serviceKasir.getDetailNotaBayarListProduk(widget.idTransaksi);
  }

  void _showQRPopup(BuildContext context, String idToko) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          content: FutureBuilder<Map<String, dynamic>>(
            future: serviceKasir.getTransaksiByToko(idToko),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!['fotoQrToko'] == null) {
                return const Center(child: Text('QR Toko tidak tersedia'));
              } else {
                final data = snapshot.data!;
                final String? base64Image = data['fotoQrToko'];

                Uint8List? qrImageBytes;
                if (base64Image != null && base64Image.isNotEmpty) {
                  qrImageBytes = base64Decode(base64Image);
                }

                return Column(
                  mainAxisSize: MainAxisSize.min, // To make dialog wrap content
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
      body: FutureBuilder<Map<String, dynamic>>(
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
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama Toko
                  Text(
                    data['namaToko'] ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Detail Transaksi
                  Text(
                    '${data['tanggalPembayaran']} - ${data['jamPembayaran']}',
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
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 16),
                        onPressed: () {
                          // Logika untuk copy kode pembayaran
                        },
                      ),
                    ],
                  ),
                  // Data No Nota
                  Text(
                    data['noNota'] ?? '',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Text('List Produk', style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(
                    child: ListView.builder(
                      itemCount: data['detailProduk'].length,
                      itemBuilder: (context, index) {
                        final produk = data['detailProduk'][index];
                        return ListTile(
                          leading: Icon(Icons.image, size: 40), 
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
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Pembayaran'),
                      Text('Rp ${data['totalBelanjaTunai']}'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Voucher'),
                      Text('${data['totalBelanjaVoucher']}'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Tampilkan pop-up QR
                          _showQRPopup(context, widget.idToko.toString());
                        },
                        child: const Text('Tampilkan QR'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(0, 84, 102, 1),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => KasirScreen(idToko: widget.idToko),
                            ),
                          );
                        },
                        child: const Text('Kembali'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
