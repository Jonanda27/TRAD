import 'dart:convert'; // Untuk menggunakan base64 decoding

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trad/Model/RestAPI/service_toko.dart';
import 'package:trad/Screen/TokoScreen/tambah_toko.dart';
import 'package:trad/bottom_navigation_bar.dart';
import 'package:trad/Model/toko_model.dart';
import 'package:trad/edit_toko.dart';

class ListTokoScreen extends StatefulWidget {
  @override
  _ListTokoScreenState createState() => _ListTokoScreenState();
}

class _ListTokoScreenState extends State<ListTokoScreen> {
  bool _isLoading = true;
  int? userId;
  List<TokoModel> tokoList = [];

  @override
  void initState() {
    super.initState();
    _fetchStores();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('id'); // Simpan userId dari SharedPreferences
  }

  Future<void> _fetchStores() async {
    try {
      List<TokoModel> stores = await TokoService().fetchStores();
      for (var store in stores) {
        print('Nomor Telepon Toko: ${store.nomorTeleponToko}');
      }
      setState(() {
        tokoList = stores;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching stores: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showDeleteConfirmation(
      BuildContext context, String storeName, int tokoId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: Text('Apakah Anda Yakin ingin Menghapus Toko $storeName?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Hapus'),
              onPressed: () async {
                Navigator.of(context).pop();
                await TokoService().hapusToko(tokoId);
                _fetchStores(); // Refresh the store list after deletion
              },
            ),
          ],
        );
      },
    );
  }

  ImageProvider<Object> _getImageProvider(String? fotoProfileToko) {
  if (fotoProfileToko != null && fotoProfileToko.isNotEmpty) {
    // Jika ini adalah string base64, konversikan menjadi MemoryImage
    if (fotoProfileToko.startsWith('/9j/')) {
      return MemoryImage(base64Decode(fotoProfileToko));
    }

    // Jika ini adalah URL, gunakan NetworkImage
    return NetworkImage(fotoProfileToko);
  }

  // Jika fotoProfileToko null atau kosong, gunakan gambar default
  return const AssetImage('assets/img/default_profile.jpg');
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(0, 84, 102, 1),
        title: const Text(
          'Daftar Toko',
          style: TextStyle(color: Colors.white, fontFamily: 'Josefin Sans'),
        ),
        actions: [
          Padding(
            padding:
                const EdgeInsets.only(right: 16.0), // Add padding to the right
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(6.0),
              ),
              child: IconButton(
                icon: const Icon(Icons.add),
                color: const Color.fromRGBO(36, 75, 89, 1),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TambahTokoScreen()),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[100],
                            hintText: 'Cari produk di toko',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                          width:
                              8), // Space between the search field and filter icon
                      Container(
                        child: IconButton(
                          icon: const Icon(Icons.filter_list),
                          onPressed: () {
                            // Handle filter action
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Jumlah Toko (${tokoList.length})'),
                      GestureDetector(
                        onTap: () {
                          // Handle "Pilih semua" action if needed
                        },
                        child: const Text(
                          'Pilih semua',
                          style:
                              TextStyle(color: Color.fromRGBO(36, 75, 89, 1)),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: tokoList.length,
                    itemBuilder: (context, index) {
                      final toko = tokoList[index];
                      String kategoriDisplay =
                          toko.kategoriToko.values.join(', ');

                      return SizedBox(
                        width: 335,
                        height: 153,
                        child: Card(
                          margin: const EdgeInsets.all(8),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1), // Gray outline
                            borderRadius: BorderRadius.circular(8),
                          ),
                          color: Colors.white, // White background
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 95,
                                    height: 95,
                                    margin: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      image: DecorationImage(
                                        image: _getImageProvider(
                                            toko.fotoProfileToko),
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            toko.namaToko,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromRGBO(
                                                    36, 75, 89, 1)),
                                          ),
                                          Text(
                                            kategoriDisplay,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Color.fromRGBO(
                                                    158, 158, 158, 1)),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            toko.alamatToko,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color:
                                                    Color.fromRGBO(0, 0, 0, 1)),
                                          ),
                                          const SizedBox(
                                              height:
                                                  4), // Space between address and province/city
                                          Text(
                                            '${toko.kotaToko}, ${toko.provinsiToko}',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color:
                                                    Color.fromRGBO(0, 0, 0, 1)),
                                          ),
                                          const SizedBox(
                                              height:
                                                  8), // Space between address and buttons
                                          Align(
                                            alignment: Alignment
                                                .bottomRight, // Align buttons to the bottom right
                                            child: Row(
                                              mainAxisSize: MainAxisSize
                                                  .min, // Ensure row size fits buttons
                                              children: [
                                                SizedBox(
                                                  width:
                                                      100, // Adjust the width as needed for "Edit Akun"
                                                  height: 28,
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .push(
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              UbahTokoScreen(
                                                            toko: toko,
                                                            idToko: toko
                                                                .id, // Mengirimkan idToko ke halaman UbahTokoScreen
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child: const Text(
                                                      'Edit Toko',
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.white),
                                                    ),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          const Color.fromRGBO(
                                                              36, 75, 89, 1),
                                                      padding: EdgeInsets
                                                          .zero, // Remove default padding
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                    width:
                                                        8), // Space between buttons
                                                SizedBox(
                                                  width: 63,
                                                  height: 28,
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      _showDeleteConfirmation(
                                                          context,
                                                          toko.namaToko,
                                                          toko.id);
                                                    },
                                                    child: const Text(
                                                      'Hapus',
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.red),
                                                    ),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          Colors.white,
                                                      side: const BorderSide(
                                                          color: Colors
                                                              .red), // Red outline
                                                      padding: EdgeInsets
                                                          .zero, // Remove default padding
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      bottomNavigationBar: MyBottomNavigationBar(
        currentIndex: 4,
        onTap: (index) {
          // Lakukan navigasi atau aksi sesuai dengan index yang dipilih
        },
        userId: userId ?? 0,
      ),
    );
  }
}
