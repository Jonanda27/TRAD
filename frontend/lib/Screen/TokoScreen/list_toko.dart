import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trad/Model/RestAPI/service_toko.dart';
import 'package:trad/Screen/HomeScreen/home_screen.dart';
import 'package:trad/Screen/TokoScreen/profile_toko.dart';
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
  String searchQuery = '';
  Timer? _debounce;
  TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _provinsiOptions = [];
  Map<String, List<Map<String, dynamic>>> _kotaCache = {};

  // Added for filter options
  List<String> selectedCategories = [];
  List<String> selectedProvinces = [];
  List<int> selectedStores = []; // Menyimpan toko yang dipilih

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _fetchProvinces(); // Fetch provinsi on init
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('id');
    if (userId != null) {
      await _fetchStores(userId!);
    }
  }

 Future<void> _fetchStores(int userId,
    {List<String>? provinsiToko, List<String>? kategori}) async {
  setState(() {
    _isLoading = true;
  });

  try {
    List<TokoModel> stores;
    if (searchQuery.isEmpty && (provinsiToko == null || provinsiToko.isEmpty) && (kategori == null || kategori.isEmpty)) {
      stores = await TokoService().fetchStores();
    } else {
      stores = await TokoService().cariTokoPenjual(
        userId: userId,
        namaToko: searchQuery,
        provinsiToko: provinsiToko, // Mengirimkan daftar provinsi
        kategori: kategori,
      );
    }

    setState(() {
      tokoList = stores;
    });

    for (final store in stores) {
      if (!_kotaCache.containsKey(store.provinsiToko)) {
        await _fetchCities(store.provinsiToko);
      }
    }
  } catch (e) {
    print('Error fetching stores: $e');
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}


  void _toggleSelectAll() {
    setState(() {
      if (selectedStores.length == tokoList.length) {
        selectedStores.clear(); // Jika semua sudah dipilih, kosongkan daftar
      } else {
        selectedStores =
            tokoList.map((toko) => toko.id).toList(); // Pilih semua toko
      }
    });
  }

  Future<void> _fetchProvinces() async {
    try {
      List<Map<String, dynamic>> provinces = await TokoService().getProvinces();
      setState(() {
        _provinsiOptions = provinces;
      });
    } catch (e) {
      print('Failed to fetch provinces: $e');
    }
  }

  Future<void> _fetchCities(String provinceId) async {
    try {
      List<Map<String, dynamic>> cities =
          await TokoService().getCities(provinceId);
      setState(() {
        _kotaCache[provinceId] = cities;
      });
    } catch (e) {
      print('Failed to fetch cities: $e');
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        searchQuery = query;
      });
      _fetchStores(userId!);
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      searchQuery = '';
    });
    _fetchStores(userId!);
  }

  String _getProvinsiName(String provinsiId) {
    final match = _provinsiOptions.firstWhere(
      (provinsi) => provinsi['id'] == provinsiId,
      orElse: () => {'nama': provinsiId},
    );
    return match['nama'];
  }

  String _getKotaName(String kotaId, String provinsiId) {
    final kotaList = _kotaCache[provinsiId] ?? [];
    final match = kotaList.firstWhere(
      (kota) => kota['id'] == kotaId,
      orElse: () => {'nama': kotaId},
    );
    return match['nama'];
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
            borderRadius: BorderRadius.circular(6.0),
          ),
          titlePadding: EdgeInsets.zero,
          title: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: const Color(0xFF337F8F),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(6.0),
              ),
            ),
            child: const Center(
              child: Text(
                'Hapus Toko',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          content: Text.rich(
            TextSpan(
              text: 'Apakah Anda Yakin ingin Menghapus Toko ', // Regular text
              style: const TextStyle(
                color: Color.fromARGB(
                    255, 0, 0, 0), // Default color for the rest of the text
              ),
              children: [
                TextSpan(
                  text: storeName, // The store name
                  style: const TextStyle(
                    fontWeight: FontWeight.bold, // Bold
                    color: Colors.black, // Black color
                  ),
                ),
                TextSpan(
                  text: '?', // Question mark after the store name
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 108, // Lebar tombol
                  height: 36, // Tinggi tombol
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color(0xFF005466),
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF005466)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                    ),
                    child: const Text('Tidak'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                const SizedBox(width: 15),
                SizedBox(
                  width: 108, // Lebar tombol
                  height: 36, // Tinggi tombol
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFFEF4444),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                    ),
                    child: const Text('Ya'),
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
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _hapusSemuaToko() async {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          titlePadding: EdgeInsets.zero,
          title: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: Color(0xFF337F8F),
              borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(
                  padding: EdgeInsets.only(
                      left: 70), // Padding kiri ditambahkan di sini
                  child: Text(
                    'Hapus Toko',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(dialogContext).pop(); // Tutup dialog
                  },
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          content: const Text(
            'Anda yakin ingin menghapus semua toko yang dipilih ?',
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Tombol "Tidak"
                SizedBox(
                  width: 105,
                  height: 36,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF005466),
                      side: const BorderSide(color: Color(0xFF005466)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                    ),
                    child: const Text('Tidak'),
                    onPressed: () {
                      Navigator.of(dialogContext).pop(); // Tutup dialog
                    },
                  ),
                ),
                const SizedBox(width: 20),
                // Tombol "Ya"
                SizedBox(
                  width: 105,
                  height: 36,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                    ),
                    child: const Text('Ya'),
                    onPressed: () async {
                      Navigator.of(dialogContext).pop(); // Tutup dialog
                      // Tunggu hingga semua toko dihapus
                      for (var tokoId in selectedStores) {
                        try {
                          await TokoService().hapusToko(tokoId);
                        } catch (e) {
                          print('Error deleting store: $e');
                        }
                      }
                      // Refresh toko list
                      await _fetchStores(userId!);

                      // Tampilkan pop-up sukses untuk hapus semua toko
                      showSuccessOverlayHapusSemua(context);

                      // Bersihkan daftar selectedStores
                      setState(() {
                        selectedStores.clear();
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

 void showSuccessOverlayHapusSemua(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0),
        ),
        titlePadding: EdgeInsets.zero,
        title: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF337F8F),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(6.0),
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0), // Menambahkan padding kiri
                child: const Text(
                  'Hapus Toko Berhasil',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => ListTokoScreen()),
                  );
                },
              ),
            ],
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
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
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
          decoration: BoxDecoration(
            color: const Color(0xFF337F8F),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(6.0),
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0), // Menambahkan padding kiri
                child: const Text(
                  'Hapus Toko Berhasil',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => ListTokoScreen()),
                  );
                },
              ),
            ],
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
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      );
    },
  );
}


  ImageProvider<Object> _getImageProvider(String? fotoProfileToko) {
    if (fotoProfileToko == null || fotoProfileToko.isEmpty) {
      return const AssetImage('assets/img/default_image.png');
    } else if (fotoProfileToko == 'default_image.png') {
      return const AssetImage('assets/img/default_image.png');
    } else if (fotoProfileToko.startsWith('/9j/')) {
      return MemoryImage(base64Decode(fotoProfileToko));
    } else {
      return NetworkImage(fotoProfileToko);
    }
  }

  void _showFilterOptions() {
  List<String> categories = [
    'Makanan',
    'Minuman',
    'Pakaian',
    // Tambahkan kategori lain sesuai kebutuhan
  ];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
    ),
    builder: (context) {
      return FractionallySizedBox(
        heightFactor: 0.8, // Tinggi modal 80% dari layar
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bagian Header dengan judul 'Filter'
                Container(
                  width: double.infinity, // Membuat kontainer selebar layar
                  padding: const EdgeInsets.all(16.0),
                  decoration: const BoxDecoration(
                    color: Color(
                        0xFFDBE7E4), // Warna latar belakang header penuh
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16.0)),
                  ),
                  child: const Text(
                    'Filter',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Warna teks header
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Bagian Filter Kategori
                        const Text(
                          'Kategori',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF005466),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Divider(color: Colors.grey[300]), // Garis pemisah
                        const SizedBox(height: 10),
                        Column(
                          children: categories.map((category) {
                            return Row(
                              children: [
                                Transform.scale(
                                  scale: 1.2, // Ukuran kotak checkbox
                                  child: Checkbox(
                                    value: selectedCategories.contains(category),
                                    onChanged: (bool? value) {
                                      setState(() {
                                        if (value == true) {
                                          selectedCategories.add(category);
                                        } else {
                                          selectedCategories.remove(category);
                                        }
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(
                                    width:
                                        13), // Jarak antara checkbox dan teks
                                Expanded(
                                  child: Text(category),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                        // Bagian Filter Provinsi
                        const Text(
                          'Provinsi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF005466),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Divider(color: Colors.grey[300]), // Garis pemisah
                        const SizedBox(height: 10),
                        // Menampilkan daftar provinsi dengan checkbox
                        Column(
                          children: _provinsiOptions.map((provinsi) {
                            return Row(
                              children: [
                                Transform.scale(
                                  scale: 1.2, // Ukuran kotak checkbox
                                  child: Checkbox(
                                    value: selectedProvinces
                                        .contains(provinsi['id']),
                                    onChanged: (bool? value) {
                                      setState(() {
                                        if (value == true) {
                                          selectedProvinces
                                              .add(provinsi['id']);
                                        } else {
                                          selectedProvinces
                                              .remove(provinsi['id']);
                                        }
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(
                                    width:
                                        13), // Jarak antara checkbox dan teks
                                Expanded(
                                  child: Text(provinsi['nama']),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Color(0xFF005466),
                          side: const BorderSide(color: Color(0xFF005466)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        onPressed: () {
                          // Reset filter yang dipilih
                          setState(() {
                            selectedCategories.clear();
                            selectedProvinces.clear();
                          });
                        },
                        child: const Text('Reset'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF005466),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        onPressed: () {
                          // Terapkan filter yang dipilih
                          String? selectedProvince =
                              selectedProvinces.isNotEmpty
                                  ? selectedProvinces.first
                                  : null;

                          // Panggil fungsi untuk fetch toko dengan filter multiple kategori
                          _fetchStores(userId!,
                               provinsiToko: selectedProvinces,
                              kategori: selectedCategories);

                          Navigator.pop(context); // Tutup modal
                        },
                        child: const Text('Terapkan'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
          style: TextStyle(color: Colors.white, fontFamily: 'Open Sans'),
        ),
        actions: [
  Padding(
    padding: const EdgeInsets.only(right: 16.0),
    child: Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF), // Background putih
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: IconButton(
        icon: SvgPicture.asset(
          'assets/svg/icons/icons-add.svg', // Sesuaikan dengan path SVG yang Anda miliki
          width: 20.0, // Ukuran ikon
          height: 20.0,
        ),
        iconSize: 40.0, // Set ukuran tombol lebih besar untuk tampilan
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TambahTokoScreen()),
          );
        },
      ),
    ),
  ),
]

      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Column(
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
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 12.0, horizontal: 16.0),
                                filled: true,
                                fillColor: const Color(0xFFEFEFEF),
                                hintText: 'Cari toko',
                                hintStyle: TextStyle(color: Colors.grey[600]),
                                prefixIcon: const Icon(Icons.search,
                                    color: Colors.grey),
                                suffixIcon: searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear,
                                            color: Colors.grey),
                                        onPressed: _clearSearch,
                                      )
                                    : null,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 255, 255, 255),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: SvgPicture.asset(
                                'assets/svg/icons/icons-filter.svg',
                                height: 40, // Set the height to 40
                                width: 40, // Set the width to 40
                              ),
                              onPressed: () {
                                _showFilterOptions(); // Show the filter modal
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Jumlah Toko (${tokoList.length})',
                              style: TextStyle(color: Colors.grey[600])),
                          GestureDetector(
                            onTap: _toggleSelectAll,
                            child: Text(
                              tokoList.isEmpty || selectedStores.isEmpty
                                  ? 'Pilih Semua'
                                  : selectedStores.length == tokoList.length
                                      ? 'Batal'
                                      : 'Pilih Semua',
                              style: const TextStyle(
                                color:
                                    Color(0xFF005466), // Change the color here
                              ),
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

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (selectedStores.isNotEmpty) {
                                  // Jika ada toko yang sudah dipilih, toggle select/deselect
                                  if (selectedStores.contains(toko.id)) {
                                    selectedStores.remove(toko
                                        .id); // Hapus dari daftar jika sudah dipilih
                                  } else {
                                    selectedStores.add(toko
                                        .id); // Tambahkan ke daftar jika belum dipilih
                                  }
                                } else {
                                  // Jika tidak ada toko yang dipilih, buka halaman ProfileTokoScreen
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProfileTokoScreen(
                                          tokoId: toko.id), // Pass tokoId
                                    ),
                                  );
                                }
                              });
                            },
                            child: Card(
                              margin: const EdgeInsets.all(8),
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: selectedStores.contains(toko.id)
                                      ? const Color(
                                          0xFF005466) // Jika dipilih, border berwarna biru
                                      : Colors.grey[
                                          300]!, // Jika tidak dipilih, border abu-abu
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              color: Colors.white,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Mengatur tinggi card
                                  Container(
                                    height: 147, // Atur tinggi sesuai kebutuhan
                                    child: Row(
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
                                            borderRadius:
                                                BorderRadius.circular(8),
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
                                                        36, 75, 89, 1),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  kategoriDisplay,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color.fromRGBO(
                                                        158, 158, 158, 1),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  toko.alamatToko,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color.fromRGBO(
                                                        0, 0, 0, 1),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Kota ${_getKotaName(toko.kotaToko, toko.provinsiToko)}, ${_getProvinsiName(toko.provinsiToko)}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color.fromRGBO(
                                                        0, 0, 0, 1),
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Align(
                                                  alignment:
                                                      Alignment.bottomRight,
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      SizedBox(
                                                        width: 70,
                                                        height: 28,
                                                        child: ElevatedButton(
                                                          onPressed: () async {
                                                            final result =
                                                                await Navigator.of(
                                                                        context)
                                                                    .push(
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        UbahTokoScreen(
                                                                  toko: toko,
                                                                  idToko:
                                                                      toko.id,
                                                                ),
                                                              ),
                                                            );
                                                            if (result !=
                                                                    null &&
                                                                result['isUpdated'] ==
                                                                    true) {
                                                              setState(() {
                                                                tokoList[
                                                                        index] =
                                                                    result[
                                                                        'updatedToko'];
                                                              });
                                                            }
                                                          },
                                                          child: const Text(
                                                            'Edit Toko',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            backgroundColor:
                                                                const Color(
                                                                    0xFF005466),
                                                            padding:
                                                                EdgeInsets.zero,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          6),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      SizedBox(
                                                        width: 70,
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
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            backgroundColor:
                                                                Colors.white,
                                                            side:
                                                                const BorderSide(
                                                                    color: Colors
                                                                        .red),
                                                            padding:
                                                                EdgeInsets.zero,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          6),
                                                            ),
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
                if (selectedStores
                    .isNotEmpty) // Jika ada toko yang dipilih, tampilkan tombol hapus
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: ElevatedButton(
                      onPressed: _hapusSemuaToko,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Hapus',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
