import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import paket flutter_svg
import 'package:trad/Model/RestAPI/service_kasir.dart';
import 'package:trad/Model/produk_model.dart';
import 'package:trad/Screen/KasirScreen/nota_list_produk.dart';

class TinjauPesanan extends StatefulWidget {
  final List<Produk> produkList;
  final Map<int, int> quantityMap;
  final int idToko; // Tambahkan parameter idToko

  TinjauPesanan({Key? key, required this.produkList, required this.quantityMap, required this.idToko})
      : super(key: key);

  @override
  _TinjauPesananState createState() => _TinjauPesananState();
}

class _TinjauPesananState extends State<TinjauPesanan> {
  bool _isExpanded = false;
  double additionalFee = 0.0;
  double additionalVoucher = 0.0;
  final ServiceKasir serviceKasir = ServiceKasir(); // Inisialisasi service

  ImageProvider<Object> _getImageProvider(String? fotoProduk) {
    if (fotoProduk == null || fotoProduk.isEmpty) {
      return const AssetImage('assets/img/default_image.png'); // Default image
    } else if (fotoProduk.startsWith('/9j/')) {
      return MemoryImage(base64Decode(fotoProduk));
    } else {
      return NetworkImage(fotoProduk);
    }
  }

  int _calculateTotalProducts() {
    // Menghitung jumlah produk berdasarkan quantity di atas 0
    return widget.quantityMap.entries.where((entry) => entry.value > 0).length;
  }

  Future<void> _buatPesanan() async {
    // Data yang akan dikirim ke API
    List<Map<String, dynamic>> barang = widget.produkList
        .where((produk) => (widget.quantityMap[produk.id] ?? 0) > 0)
        .map((produk) => {
              'idProduk': produk.id,
              'jumlah': widget.quantityMap[produk.id],
              'kodeVoucher': null, // Atur sesuai kebutuhan
            })
        .toList();

    try {
      // Memanggil service untuk membuat pesanan
      final response = await serviceKasir.listProdukToko(
        widget.idToko.toString(), // Gunakan idToko dari widget
        barang,
        additionalFee,
        additionalVoucher,
      );

      if (response.containsKey('error')) {
        // Menampilkan pesan kesalahan jika ada
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text(response['error']),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        // Tampilkan notifikasi sukses dan arahkan ke halaman NotaListProduk
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Sukses'),
            content: Text('Pesanan berhasil dibuat!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Tutup dialog
                  // Navigasi ke halaman NotaListProduk dengan ID transaksi
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotaListProduk(
                        idTransaksi: response['id'].toString(), // Kirim ID transaksi
                        idToko: widget.idToko, // Menambahkan idToko untuk mencegah error
                      ),
                    ),
                  );
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Tangani kesalahan lain
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Kesalahan'),
          content: Text('Terjadi kesalahan: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalPembayaran = 0;
    double totalVoucher = 0;

    widget.produkList.forEach((produk) {
      totalPembayaran += (produk.harga * (widget.quantityMap[produk.id] ?? 0));
      totalVoucher += (double.tryParse(produk.voucher ?? '0') ?? 0) *
          (widget.quantityMap[produk.id] ?? 0);
    });

    double grandTotal = totalPembayaran + additionalFee;
    double grandTotalVoucher = totalVoucher + additionalVoucher;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(0, 84, 102, 1),
        title: const Text('Tinjau Pesanan', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Input List Produk',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF005466),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.produkList.length,
              itemBuilder: (context, index) {
                final produk = widget.produkList[index];
                final quantity = widget.quantityMap[produk.id] ?? 0;

                return Container(
                  width: 328,
                  height: 125,
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: Color(0xFFDEE2E9),
                        width: 1.0,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 16.0),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey[200],
                                  child: produk.fotoProduk.isNotEmpty
                                      ? Image(
                                          image: _getImageProvider(
                                              produk.fotoProduk[0]),
                                          fit: BoxFit.cover,
                                        )
                                      : const Icon(Icons.image_not_supported),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      produk.namaProduk,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF005466),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Harga : Rp ${produk.harga},-',
                                      style: const TextStyle(
                                        color: Color(0xFF7B8794),
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      'Voucher : ${produk.voucher ?? '0'}',
                                      style: const TextStyle(
                                        color: Color(0xFF7B8794),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            height: 30,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFFD1D5DB),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFD9DCE1),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(6),
                                      bottomLeft: Radius.circular(6),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '-',
                                      style: const TextStyle(
                                        color: Color(0xFFAFB4BE),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 30,
                                  height: 30,
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                    color: Colors.white, // Background putih untuk quantity
                                  ),
                                  child: Text(
                                    '$quantity', // Display current quantity
                                    style: const TextStyle(
                                      color: Color(0xFFAFB4BE),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFD9DCE1),
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(6),
                                      bottomRight: Radius.circular(6),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '+',
                                      style: const TextStyle(
                                        color: Color(0xFFAFB4BE),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Divider(
            color: Colors.grey[300],
            thickness: 1.0,
          ),
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
                            'Total Pesanan (${_calculateTotalProducts()} Produk)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF7B8794),
                            ),
                          ),
                          Row(
                            children: [
                              const SizedBox(width: 4),
                              Text(
                                'Rp. ${totalPembayaran.toString()},-',
                                style: const TextStyle(
                                  color: Color(0xFF005466),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 130),
                              SvgPicture.asset(
                                'assets/svg/icons/icons-voucher.svg',
                                width: 18,
                                height: 18,
                                color: Color(0xFF005466),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${totalVoucher.toString()}',
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
                          color: Color(0xFF9CA3AF), // Warna teks
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
          Divider(
            color: Colors.grey[300],
            thickness: 1.0,
          ),
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
                        const Text('Total Pembayaran',
                            style: TextStyle(fontWeight: FontWeight.bold)),
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
                              'Rp. ${grandTotal.toString()},-',
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
                    const SizedBox(width: 65),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('',
                            style: TextStyle(fontWeight: FontWeight.bold)),
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
                              '${grandTotalVoucher.toString()}',
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
                Container(
                  width: 154,
                  child: ElevatedButton(
                    onPressed: () {
                      // Logika untuk Batal
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Color(0xFF005466)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'Batal',
                      style: TextStyle(
                        color: Color(0xFF005466),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 154,
                  child: ElevatedButton(
                    onPressed: _buatPesanan, // Panggil fungsi untuk membuat pesanan
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF005466),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'Buat Pesanan',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16), // Margin bawah
        ],
      ),
    );
  }
}
