import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:trad/Model/RestAPI/service_kasir.dart';

class FotoQris extends StatefulWidget {
  final String idToko; // ID Toko yang diteruskan ke halaman ini

  FotoQris({Key? key, required this.idToko}) : super(key: key);

  @override
  _FotoQrisState createState() => _FotoQrisState();
}

class _FotoQrisState extends State<FotoQris> {
  late Future<Map<String, dynamic>> futureTokoData;
  final ServiceKasir serviceKasir = ServiceKasir(); // Inisialisasi Service

  @override
  void initState() {
    super.initState();
    // Panggil service untuk mendapatkan data toko
    futureTokoData = serviceKasir.getTransaksiByToko(widget.idToko);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(0, 84, 102, 1),
        title: const Text('QR Toko', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: futureTokoData,
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

            return Center( // Menggunakan Center untuk menempatkan konten di tengah
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
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
                      width: 220,  // Mengatur lebar gambar
                      height: 220, // Mengatur tinggi gambar
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
                  ElevatedButton(
                    onPressed: () {
                      // Tambahkan logika untuk mengunduh gambar QR
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF005466),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'Unduh QR',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
