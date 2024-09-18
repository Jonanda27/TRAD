import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
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

  Future<void> _fetchStores(int userId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<TokoModel> stores;
      if (searchQuery.isEmpty) {
        stores = await TokoService().fetchStores();
      } else {
        stores = await TokoService().cariToko(
          userId: userId,
          namaToko: searchQuery,
        );
      }

      setState(() {
        tokoList = stores;
        _isLoading = false;
      });

      // Load city data only for the selected province
      for (final store in stores) {
        if (!_kotaCache.containsKey(store.provinsiToko)) {
          await _fetchCities(store.provinsiToko);
        }
      }
    } catch (e) {
      print('Error fetching stores: $e');
      setState(() {
        _isLoading = false;
      });
    }
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
              child:
                  const Text('OK', style: TextStyle(color: Color(0xFF005466))),
            ),
          ],
        );
      },
    );
  }

  ImageProvider<Object> _getImageProvider(String? fotoProfileToko) {
    if (fotoProfileToko == null || fotoProfileToko.isEmpty) {
      return const AssetImage('img/default_image.png');
    } else if (fotoProfileToko == 'default_image.png') {
      return const AssetImage('img/default_image.png');
    } else if (fotoProfileToko.startsWith('/9j/')) {
      return MemoryImage(base64Decode(fotoProfileToko));
    } else {
      return NetworkImage(fotoProfileToko);
    }
  }

  // Filter modal method
  void _showFilterOptions() {
    List<String> categories = [
      'Makanan',
      'Minuman',
      'Pakaian',
      
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.8,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: const Text(
                      'Filter',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Kategori',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Displaying Categories with Checkboxes
                            Column(
                              children: categories.map((category) {
                                return CheckboxListTile(
                                  title: Text(category),
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
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Provinsi',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Displaying Provinces with Checkboxes
                            Column(
                              children: _provinsiOptions.map((provinsi) {
                                return CheckboxListTile(
                                  title: Text(provinsi['nama']),
                                  value: selectedProvinces
                                      .contains(provinsi['id']),
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        selectedProvinces.add(provinsi['id']);
                                      } else {
                                        selectedProvinces.remove(provinsi['id']);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
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
                            // Clear selected filters
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
                            // Apply filter logic here
                            Navigator.pop(context);
                          },
                          child: const Text('Apply'),
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
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 16.0),
                            filled: true,
                            fillColor: const Color(0xFFEFEFEF),
                            hintText: 'Cari produk di toko',
                            hintStyle: TextStyle(color: Colors.grey[600]),
                            prefixIcon:
                                const Icon(Icons.search, color: Colors.grey),
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
                          color: const Color(0xFFEFEFEF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon:
                              const Icon(Icons.filter_list, color: Colors.grey),
                          onPressed: () {
                            _showFilterOptions(); // Show the filter modal
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
                      Text('Jumlah Toko (${tokoList.length})',
                          style: TextStyle(color: Colors.grey[600])),
                      GestureDetector(
                        onTap: () {
                          // Tambahkan logika untuk "Pilih semua" jika diperlukan
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
                    child: tokoList.isEmpty
                        ? const Center(
                            child: Text(
                              'Toko tidak ada',
                              style: TextStyle(
                                fontSize: 18,
                                color: Color.fromRGBO(36, 75, 89, 1),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ListView.builder(
                            itemCount: tokoList.length,
                            itemBuilder: (context, index) {
                              final toko = tokoList[index];
                              String kategoriDisplay =
                                  toko.kategoriToko.values.join(', ');

                              return GestureDetector(
                                onTap: () {
                                  // Navigate to ProfileTokoScreen when the card is tapped
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ProfileTokoScreen(tokoId: toko.id),
                                    ),
                                  );
                                },
                                child: Card(
                                  margin: const EdgeInsets.all(8),
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        color: Colors.grey[300]!, width: 1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  color: Colors.white,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    toko.namaToko,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                                        color: Color.fromRGBO(
                                                            0, 0, 0, 1)),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    '${_getKotaName(toko.kotaToko, toko.provinsiToko)}, ${_getProvinsiName(toko.provinsiToko)}',
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Color.fromRGBO(
                                                            0, 0, 0, 1)),
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
                                                          width: 100,
                                                          height: 28,
                                                          child: ElevatedButton(
                                                            onPressed:
                                                                () async {
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
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              backgroundColor:
                                                                  const Color
                                                                      .fromRGBO(
                                                                      36,
                                                                      75,
                                                                      89,
                                                                      1),
                                                              padding:
                                                                  EdgeInsets
                                                                      .zero,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 8),
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
                                                                  color: Colors
                                                                      .red),
                                                            ),
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              backgroundColor:
                                                                  Colors.white,
                                                              side: const BorderSide(
                                                                  color: Colors
                                                                      .red),
                                                              padding:
                                                                  EdgeInsets
                                                                      .zero,
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
                          )),
              ],
            ),
    );
  }
}
