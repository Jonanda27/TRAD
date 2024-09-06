import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:trad/Model/RestAPI/service_kasir.dart';

class NotaTransaksi extends StatefulWidget {
  final String idTransaksi; // ID Transaksi yang diteruskan ke halaman ini

  NotaTransaksi({Key? key, required this.idTransaksi}) : super(key: key);

  @override
  _NotaTransaksiState createState() => _NotaTransaksiState();
}

class _NotaTransaksiState extends State<NotaTransaksi> {
  late Future<Map<String, dynamic>> futureDetailNota;
  final ServiceKasir serviceKasir = ServiceKasir(); // Inisialisasi Service

  @override
  void initState() {
    super.initState();
    // Panggil service untuk mendapatkan detail nota berdasarkan ID transaksi
    futureDetailNota = serviceKasir.getDetailNotaBayarListProduk(widget.idTransaksi);
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
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama Toko dan Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        data['namaToko'] ?? '',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Text(
                          data['status'] ?? '',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
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
                  // Kode Pembayaran dan Tombol QR
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kode Pembayaran:',
                            style: const TextStyle(
                              color: Color(0xFF005466), // Warna teks Kode Pembayaran
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            data['noNota'] ?? '',
                            style: const TextStyle(
                              color: Colors.black, // Warna teks hitam
                              fontWeight: FontWeight.bold, // Bold
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 16),
                        onPressed: () {
                          // Logika untuk copy kode pembayaran
                        },
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Logika untuk menampilkan QR
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(0, 84, 102, 1),
                        ),
                        child: const Text('Tampilkan QR'),
                      ),
                    ],
                  ),
                  const Divider(),
                  const Text('List Produk', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  // Daftar Produk
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: data['detailProduk'].length,
                    itemBuilder: (context, index) {
                      final produk = data['detailProduk'][index];
                      return ListTile(
                        leading: Icon(Icons.image, size: 40), // Ganti dengan gambar produk jika ada
                        title: Text(produk['namaProduk']),
                        subtitle: Row(
                          children: [
                            Text('Rp ${produk['harga']},-'),
                            const SizedBox(width: 10),
                            Text('x ${produk['jumlah']}'),
                          ],
                        ),
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Rp ${produk['totalHarga']},-'),
                            const SizedBox(height: 4),
                            Text('${produk['voucher'] ?? '0'}'),
                          ],
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  // Total Pembayaran
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.attach_money, size: 18),
                          const SizedBox(width: 4),
                          Text('Rp ${data['totalBelanjaTunai']},-', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.confirmation_number, size: 18),
                          const SizedBox(width: 4),
                          Text('${data['totalBelanjaVoucher']}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Tombol Aksi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Logika untuk membatalkan transaksi
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Colors.red),
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
                          backgroundColor: Color(0xFF005466),
                        ),
                        child: const Text(
                          'Terima',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
