import 'dart:async'; // Untuk menggunakan debounce
import 'dart:convert'; // Untuk menggunakan base64 decoding
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trad/Model/RestAPI/service_toko.dart';
import 'package:trad/Screen/HomeScreen/home_screen.dart';
import 'package:trad/Screen/TokoScreen/tambah_toko.dart';
import 'package:trad/Model/toko_model.dart';
import 'package:trad/Screen/TokoScreen/edit_toko.dart';

class ListTokoScreen extends StatefulWidget {
  @override
  _ListTokoScreenState createState() => _ListTokoScreenState();
}

class _ListTokoScreenState extends State<ListTokoScreen> {
  bool _isLoading = true;
  int? userId;
  List<TokoModel> tokoList = [];
  String searchQuery = ''; // Menyimpan kata kunci pencarian
  Timer? _debounce; // Timer untuk debounce
  TextEditingController _searchController = TextEditingController(); // Controller untuk TextField

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  @override
  void dispose() {
    _debounce?.cancel(); // Batalkan debounce saat widget dihapus
    _searchController.dispose(); // Hapus controller saat widget dihapus
    super.dispose();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('id'); // Simpan userId dari SharedPreferences
    if (userId != null) {
      await _fetchStores(userId!); // Panggil fungsi untuk mengambil toko berdasarkan userId
    }
  }

  Future<void> _fetchStores(int userId) async {
    setState(() {
      _isLoading = true; // Mulai loading
    });

    try {
      List<TokoModel> stores;
      if (searchQuery.isEmpty) {
        // Jika searchQuery kosong, ambil semua toko untuk userId
        stores = await TokoService().fetchStores();
      } else {
        // Jika searchQuery tidak kosong, gunakan cariToko untuk mencari toko
        stores = await TokoService().cariToko(
          namaToko: searchQuery, // Gunakan kata kunci pencarian
        );
      }

      setState(() {
        tokoList = stores;
        _isLoading = false; // Selesai loading
      });
    } catch (e) {
      print('Error fetching stores: $e');
      setState(() {
        _isLoading = false; // Selesai loading
      });
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        searchQuery = query; // Set kata kunci pencarian
      });
      _fetchStores(userId!); // Panggil pencarian toko
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear(); // Hapus teks di TextField
      searchQuery = ''; // Reset pencarian
    });
    _fetchStores(userId!); // Ambil semua toko untuk userId
  }

  void _showDeleteConfirmation(
    BuildContext parentContext,
    String storeName,
    int tokoId,
  ) {
    showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          titlePadding: EdgeInsets.zero,
          title: Container(
            color: const Color(0xFF337F8F),
            padding: const EdgeInsets.all(16.0),
            child: const Center(
              child: Text(
                'Hapus Toko',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          content: Text(
            'Apakah Anda Yakin ingin Menghapus Toko $storeName?',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF005466),
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: const Color(0xFF005466),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF005466)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10.0),
                  ),
                  child: const Text('Batal'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFFEF4444),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10.0),
                  ),
                  child: const Text('Hapus'),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    try {
                      await TokoService().hapusToko(tokoId);
                      showSuccessOverlay(parentContext);
                      _fetchStores(userId!);
                    } catch (e) {
                      print('Error deleting store: $e');
                    }
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void showSuccessOverlay(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          titlePadding: EdgeInsets.zero,
          title: Container(
            color: const Color(0xFF337F8F),
            padding: const EdgeInsets.all(16.0),
            child: const Center(
              child: Text(
                'Hapus Toko Berhasil',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 48,
              ),
              SizedBox(height: 16),
              Text(
                'Toko berhasil dihapus',
                style: TextStyle(
                  color: Color(0xFF005466),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ListTokoScreen()),
                );
              },
              child: const Text('OK', style: TextStyle(color: Color(0xFF005466))),
            ),
          ],
        );
      },
    );
  }

  ImageProvider<Object> _getImageProvider(String? fotoProfileToko) {
    if (fotoProfileToko == null || fotoProfileToko.isEmpty) {
      return const AssetImage('assets/img/default_image.png');
    } else if (fotoProfileToko.startsWith('/9j/')) {
      return MemoryImage(base64Decode(fotoProfileToko));
    } else {
      return NetworkImage(fotoProfileToko);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(0, 84, 102, 1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
        ),
        title: const Text(
          'Daftar Toko',
          style: TextStyle(color: Colors.white, fontFamily: 'Josefin Sans'),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
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
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                            filled: true,
                            fillColor: const Color(0xFFEFEFEF), // Warna latar belakang yang lebih terang
                            hintText: 'Cari produk di toko',
                            hintStyle: TextStyle(color: Colors.grey[600]), // Gaya teks petunjuk
                            prefixIcon: const Icon(Icons.search, color: Colors.grey), // Ikon pencarian
                            suffixIcon: searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, color: Colors.grey),
                                    onPressed: _clearSearch,
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none, // Menghilangkan border
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFEFEF), // Warna latar belakang untuk ikon filter
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.filter_list, color: Colors.grey),
                          onPressed: () {
                            // Tambahkan logika untuk filter jika diperlukan
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Jumlah Toko (${tokoList.length})', style: TextStyle(color: Colors.grey[600])),
                      GestureDetector(
                        onTap: () {
                          // Tambahkan logika untuk "Pilih semua" jika diperlukan
                        },
                        child: const Text(
                          'Pilih semua',
                          style: TextStyle(color: Color.fromRGBO(36, 75, 89, 1)),
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

                      return Card(
                        margin: const EdgeInsets.all(8),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        color: Colors.white,
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
                                              color: Color.fromRGBO(0, 0, 0, 1)),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${toko.kotaToko}, ${toko.provinsiToko}',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Color.fromRGBO(0, 0, 0, 1)),
                                        ),
                                        const SizedBox(height: 8),
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(
                                                width: 100,
                                                height: 28,
                                                child: ElevatedButton(
                                                  onPressed: () async {
                                                    final result = await Navigator.of(
                                                            context)
                                                        .push(
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            UbahTokoScreen(
                                                          toko: toko,
                                                          idToko: toko.id,
                                                        ),
                                                      ),
                                                    );

                                                    if (result != null &&
                                                        result['isUpdated'] ==
                                                            true) {
                                                      setState(() {
                                                        tokoList[index] =
                                                            result['updatedToko'];
                                                      });
                                                    }
                                                  },
                                                  child: const Text(
                                                    'Edit Toko',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.white),
                                                  ),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color.fromRGBO(
                                                            36, 75, 89, 1),
                                                    padding: EdgeInsets.zero,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
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
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.white,
                                                    side: const BorderSide(
                                                        color: Colors.red),
                                                    padding: EdgeInsets.zero,
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
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

