import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:trad/Model/RestAPI/service_produk.dart';
import 'package:trad/Model/produk_model.dart';
import 'package:trad/Screen/KasirScreen/tinjau_pesanan.dart';
import 'package:trad/Model/RestAPI/service_kasir.dart'; // Import ServiceKasir

class ListProdukKasir extends StatefulWidget {
  final int id; // ID dari tabel toko (idToko)

  const ListProdukKasir({Key? key, required this.id}) : super(key: key);

  @override
  _ListProdukKasirState createState() => _ListProdukKasirState();
}

class _ListProdukKasirState extends State<ListProdukKasir> {
  late Future<Map<String, dynamic>> futureTokoData; // Future untuk data toko
  late Future<List<Produk>> futureProdukList;
  List<int> selectedProduk = [];
  Map<int, int> quantityMap = {}; // Map untuk melacak quantity per produk

  @override
  void initState() {
    super.initState();
    // Panggil service untuk mendapatkan data toko
    futureTokoData = ServiceKasir().getTransaksiByToko(widget.id.toString());
    futureProdukList = ProdukService().fetchProdukByTokoId(widget.id);
  }

  void _increaseQuantity(int produkId) {
    setState(() {
      if (!quantityMap.containsKey(produkId)) {
        quantityMap[produkId] = 1;
      } else {
        quantityMap[produkId] = (quantityMap[produkId] ?? 0) + 1;
      }
    });
  }

  void _decreaseQuantity(int produkId) {
    setState(() {
      if (quantityMap.containsKey(produkId) && quantityMap[produkId]! > 0) {
        quantityMap[produkId] =
            (quantityMap[produkId]! - 1).clamp(0, double.infinity).toInt();
      }
    });
  }

  ImageProvider<Object> _getImageProvider(String? fotoProduk) {
    if (fotoProduk == null || fotoProduk.isEmpty) {
      return const AssetImage(
          'assets/img/default_image.png'); // Provide a default image
    } else if (fotoProduk.startsWith('/9j/')) {
      return MemoryImage(base64Decode(fotoProduk));
    } else {
      return NetworkImage(fotoProduk);
    }
  }

  bool _hasSelectedProducts() {
    return quantityMap.values.any((quantity) => quantity > 0);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: futureTokoData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!['namaToko'] == null) {
          return const Center(child: Text('Toko tidak ditemukan'));
        } else {
          final String namaToko = snapshot.data!['namaToko'] ?? 'Nama tidak tersedia';

          return MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                backgroundColor: const Color.fromRGBO(0, 84, 102, 1),
                title: Text(
                  namaToko, // Gunakan nama toko dari data yang didapatkan
                  style: const TextStyle(color: Colors.white),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () {
                      // Logika untuk pencarian
                    },
                  ),
                ],
              ),
              body: ProdukKasirList(id: widget.id),
            ),
          );
        }
      },
    );
  }
}

class ProdukKasirList extends StatefulWidget {
  final int id;

  const ProdukKasirList({Key? key, required this.id}) : super(key: key);

  @override
  _ProdukKasirListState createState() => _ProdukKasirListState();
}

class _ProdukKasirListState extends State<ProdukKasirList> {
  late Future<List<Produk>> futureProdukList;
  List<int> selectedProduk = [];
  Map<int, int> quantityMap = {}; // Map untuk melacak quantity per produk

  @override
  void initState() {
    super.initState();
    futureProdukList = ProdukService().fetchProdukByTokoId(widget.id);
  }

  void _increaseQuantity(int produkId) {
    setState(() {
      if (!quantityMap.containsKey(produkId)) {
        quantityMap[produkId] = 1;
      } else {
        quantityMap[produkId] = (quantityMap[produkId] ?? 0) + 1;
      }
    });
  }

  void _decreaseQuantity(int produkId) {
    setState(() {
      if (quantityMap.containsKey(produkId) && quantityMap[produkId]! > 0) {
        quantityMap[produkId] =
            (quantityMap[produkId]! - 1).clamp(0, double.infinity).toInt();
      }
    });
  }

  ImageProvider<Object> _getImageProvider(String? fotoProduk) {
    if (fotoProduk == null || fotoProduk.isEmpty) {
      return const AssetImage(
          'assets/img/default_image.png'); // Provide a default image
    } else if (fotoProduk.startsWith('/9j/')) {
      return MemoryImage(base64Decode(fotoProduk));
    } else {
      return NetworkImage(fotoProduk);
    }
  }

  bool _hasSelectedProducts() {
    return quantityMap.values.any((quantity) => quantity > 0);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Produk>>(
      future: futureProdukList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No products available'));
        } else {
          final produkList = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Input List Produk',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF005466),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: produkList.length,
                    itemBuilder: (context, index) {
                      final produk = produkList[index];
                      final isActive = produk.statusProduk == 'aktif'; // Status produk saat ini
                      int quantity =
                          quantityMap[produk.id] ?? 0; // Default quantity to 0

                      return Container(
                        width: 328, // Set width to 328
                        height: 125, // Set height to 125
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Card(
                          color: isActive ? Colors.white : Colors.grey[200], // Disable card jika status nonaktif
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(
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
                                      borderRadius: BorderRadius.circular(
                                          6), // Set border radius for image
                                      child: Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                        ),
                                        child: produk.fotoProduk.isNotEmpty
                                            ? Image(
                                                image: _getImageProvider(
                                                    produk.fotoProduk[0]),
                                                fit: BoxFit.cover,
                                              )
                                            : const Icon(
                                                Icons.image_not_supported),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            produk.namaProduk,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: isActive ? Color(0xFF005466) : Colors.grey, // Ubah warna teks berdasarkan status
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Harga : Rp ${produk.harga},-',
                                            style: TextStyle(
                                              color: isActive ? Color(0xFF7B8794) : Colors.grey, // Ubah warna teks berdasarkan status
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            'Voucher : ${produk.voucher ?? '0'}',
                                            style: TextStyle(
                                              color: isActive ? Color(0xFF7B8794) : Colors.grey, // Ubah warna teks berdasarkan status
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isActive) // Tampilkan opsi hanya jika produk aktif
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: PopupMenuButton(
                                    onSelected: (value) {
                                      // Logika untuk menangani item yang dipilih
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Text('Edit'),
                                        ),
                                        const PopupMenuItem(
                                          value: 'hapus',
                                          child: Text('Hapus'),
                                        ),
                                      ];
                                    },
                                    icon: Icon(Icons.more_vert,
                                        color: Colors.grey[600]),
                                  ),
                                ),
                              if (isActive) // Tampilkan tombol hanya jika produk aktif
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: Container(
                                    height:
                                        30, // Ukuran yang lebih kecil untuk tombol
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                          color: const Color(0xFFD1D5DB)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 30,
                                          height: 30,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF005466),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(6),
                                              bottomLeft: Radius.circular(6),
                                            ),
                                          ),
                                          child: IconButton(
                                            icon: const Icon(Icons.remove,
                                                color: Colors.white, size: 16),
                                            onPressed: () {
                                              _decreaseQuantity(produk.id);
                                            },
                                          ),
                                        ),
                                        Container(
                                          color: const Color(
                                              0xFFF9FAFB), // Background for quantity
                                          alignment: Alignment.center,
                                          width:
                                              30, // Ukuran yang lebih kecil untuk teks jumlah
                                          child: Text(
                                            '$quantity', // Display current quantity
                                            style: const TextStyle(
                                              fontSize:
                                                  14, // Ukuran teks lebih kecil
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF005466),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: 30,
                                          height: 30,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF005466),
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(6),
                                              bottomRight: Radius.circular(6),
                                            ),
                                          ),
                                          child: IconButton(
                                            icon: const Icon(Icons.add,
                                                color: Colors.white, size: 16),
                                            onPressed: () {
                                              _increaseQuantity(produk.id);
                                            },
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
                const SizedBox(width: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 154, // Lebar tombol
                      height: 40, // Tinggi tombol
                      child: ElevatedButton(
                        onPressed: _hasSelectedProducts()
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TinjauPesanan(
                                      produkList: produkList,
                                      quantityMap: quantityMap,
                                      idToko: widget.id, // Kirim idToko dari widget ini
                                    ),
                                  ),
                                );
                              }
                            : null, // Disable the button if no products are added
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _hasSelectedProducts()
                              ? const Color(0xFF005466)
                              : Colors.grey, // Change button color based on product selection
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6), // Radius button
                          ),
                        ),
                        child: const Text(
                          'Selanjutnya',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
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
    );
  }
}
