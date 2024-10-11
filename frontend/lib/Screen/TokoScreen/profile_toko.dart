import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:trad/Model/RestAPI/service_toko.dart';
import 'package:trad/Model/toko_model.dart';
import 'package:trad/Screen/HomeScreen/home_screen.dart';
import 'package:trad/Screen/TokoScreen/edit_toko.dart';
import 'package:trad/bottom_navigation_bar.dart';
import 'package:trad/list_produk.dart';

class ProfileTokoScreen extends StatefulWidget {
  final int tokoId;

  ProfileTokoScreen({required this.tokoId});

  @override
  _ProfileTokoScreenState createState() => _ProfileTokoScreenState();
}

class _ProfileTokoScreenState extends State<ProfileTokoScreen> {
  late Future<Map<String, dynamic>> _profileData;
  bool isExpanded = false;
  
  // Cache untuk menyimpan data provinsi dan kota
  List<Map<String, dynamic>> _provinsiOptions = [];
  Map<String, List<Map<String, dynamic>>> _kotaCache = {};

  @override
  void initState() {
    super.initState();
    _profileData = TokoService().profileToko(widget.tokoId);
    _fetchProvinces(); // Fetch provinsi ketika halaman dibuka
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

  // Fungsi untuk mendapatkan nama provinsi
  String _getProvinsiName(String provinsiId) {
    final match = _provinsiOptions.firstWhere(
      (provinsi) => provinsi['id'] == provinsiId,
      orElse: () => {'nama': provinsiId},
    );
    return match['nama'];
  }

  // Fungsi untuk mendapatkan nama kota berdasarkan ID dan provinsi ID
  String _getKotaName(String kotaId, String provinsiId) {
    final kotaList = _kotaCache[provinsiId] ?? [];
    final match = kotaList.firstWhere(
      (kota) => kota['id'] == kotaId,
      orElse: () => {'nama': kotaId},
    );
    return match['nama'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF06444A), // Dark teal
        title: const Text('Profil Toko', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share, color: Colors.white),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Data tidak tersedia'));
          }

          final profile = snapshot.data!['profileData'];
          final List<dynamic>? operationalHours = profile['jam_operasional'] as List<dynamic>?;

          final String? fotoProfileToko = profile['fotoProfileToko'];
          final String provinsiId = profile['provinsiToko'];
          final String kotaId = profile['kotaToko'];

          // Decode the base64 image if it exists, otherwise use default image
          ImageProvider<Object>? imageProvider;
          if (fotoProfileToko != null && fotoProfileToko.isNotEmpty) {
            try {
              final decodedBytes = base64Decode(fotoProfileToko);
              imageProvider = MemoryImage(decodedBytes);
            } catch (e) {
              print('Error decoding base64 image: $e');
              imageProvider = const AssetImage('assets/img/default_image.png'); // Use default image on error
            }
          } else {
            imageProvider = const AssetImage('assets/img/default_image.png'); // Use default image when null or empty
          }

          // Jika data kota belum di-cache, ambil kota berdasarkan provinsi toko
          if (!_kotaCache.containsKey(provinsiId)) {
            _fetchCities(provinsiId);
          }

           final List<dynamic>? kategoriToko = profile['kategori_toko'] as List<dynamic>?;

          // Jika kategori_toko tidak null dan berisi data, tampilkan kategori, jika tidak tampilkan "Kategori tidak tersedia"
          String kategoriDisplay = "Kategori tidak tersedia";
          if (kategoriToko != null && kategoriToko.isNotEmpty) {
            kategoriDisplay = kategoriToko.map((item) => item['kategori']).join(', ');
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section with Store Information
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white, // White background
                  child: Row(
                    children: [
                      // Store image placeholder
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200, // Placeholder image background
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Container(
                          width: 100.0,
                          height: 100.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Store details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile['namaToko'] ?? 'Nama tidak tersedia',
                              style: const TextStyle(
                                color: Color(0xFF005466),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Bagian kategori yang sudah dinamis
                            Text(
                              kategoriDisplay,
                              style: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              profile['alamatToko'] ?? 'Alamat tidak tersedia',
                              style: const TextStyle(color: Color(0xFF212121), fontSize: 12),
                            ),
                            // Menambahkan tampilan provinsi dan kota toko
                            Text(
                              'Kota: ${_getKotaName(kotaId, provinsiId)}, ${_getProvinsiName(provinsiId)}',
                              style: const TextStyle(color: Color(0xFF212121), fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.phone, color: Color(0xFF005466), size: 14),
                                const SizedBox(width: 4),
                                Text(profile['nomorTeleponToko'] ?? 'Telepon tidak tersedia',
                                    style: const TextStyle(color: Color(0xFF005466), fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Point and Voucher Info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buildInfoColumnWithLeftIcon(Icons.wallet, 'Saldo Poin Toko', profile['tradPoint']?.toString() ?? 'N/A'),
                      buildInfoColumnWithLeftIcon(Icons.local_offer, 'Rentang Voucher', profile['voucherToko'] ?? 'N/A'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Product Count and Bank Account Info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: buildInfoColumnWithLeftIcon(
                          Icons.inventory,
                          'Jumlah Produk',
                          profile['jumlahProduk']?.toString() ?? '0',
                          isEditable: true,
                          onEdit: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ListProduk(id: widget.tokoId),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8.0), // Add some spacing between columns
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              buildInfoColumnWithLeftIcon(
                                Icons.account_balance,
                                'Rekening Toko',
                                '${profile['namaBank'] ?? 'Bank tidak tersedia'} - ${profile['nomorRekening'] ?? 'Nomor tidak tersedia'}',
                                isEditable: true,
                              ),
                            ],
                          ),
                        )
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Operational Hours
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isExpanded = !isExpanded;
                          });
                        },
                        child: Row(
                          children: [
                            Icon(Icons.access_time, color: Colors.grey.shade800),
                            const SizedBox(width: 8),
                            Text(
                              'Jam Operasional',
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
                            ),
                            Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.grey.shade800),
                          ],
                        ),
                      ),
                      if (isExpanded && operationalHours != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 24.0, top: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: operationalHours.map((item) {
                              return Text(
                                '${item['hari']} ${item['jamBuka']}–${item['jamTutup']}',
                                style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
                              );
                            }).toList(),
                          ),
                        )
                      else if (isExpanded)
                        Padding(
                          padding: const EdgeInsets.only(left: 24.0, top: 8.0),
                          child: Text(
                            'Jam operasional tidak tersedia',
                            style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Store Settings Section
                buildSectionTitle('Pengaturan Toko'),
                buildMenuItem(
                  'Edit Toko',
                  Icons.edit,
                  onTap: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => UbahTokoScreen(
                          toko: TokoModel.fromJson(profile),
                          idToko: profile['id'] ?? 0,
                        ),
                      ),
                    );

                    if (result != null && result['isUpdated'] == true) {
                      setState(() {
                        _profileData = TokoService().profileToko(widget.tokoId);
                      });
                    }
                  },
                ),
                ListTile(
                  title: const Text('Hapus Toko', style: TextStyle(color: Colors.red)),
                  onTap: () => _showDeleteConfirmation(context),
                ),

                const SizedBox(height: 16),

                // Point Services Section
                buildSectionTitle('Layanan Poin dan lainnya'),
                buildMenuItem('Pencairan Poin Toko', Icons.money, onTap: () {}),
                buildMenuItem('Jual Subscription TRAD', Icons.subscriptions, onTap: () {}),
                buildMenuItem('Pusat Bantuan TRAD Care', Icons.help_center, onTap: () {}),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: MyBottomNavigationBar(
        currentIndex: 4, // Set currentIndex sesuai dengan posisi tab
        onTap: (index) {
          setState(() {
            // Perbarui currentIndex saat user menekan navigasi bawah
          });
        },
        userId: widget.tokoId, // Berikan tokoId sebagai userId
      ),
    );
  }

  Widget buildInfoColumnWithLeftIcon(IconData icon, String value, String title, {bool isEditable = false, VoidCallback? onEdit}) {
    return Row(
      children: [
        Icon(icon, color: Colors.teal.shade800, size: 30), // Dark teal icons
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isEditable) ...[
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: onEdit,
                    child: Icon(Icons.edit_square, size: 16, color: Colors.teal.shade800),
                  ),
                ]
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget buildSectionTitle(String title) {
    return Container(
      color: Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      width: double.infinity,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade800,
        ),
      ),
    );
  }

  Widget buildMenuItem(String title, IconData icon, {required VoidCallback onTap, bool isDelete = false}) {
    return ListTile(
      title: Text(title, style: TextStyle(color: isDelete ? Colors.red : Colors.black)),
      onTap: onTap,
      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade600), // Grey chevron arrow
    );
  }

  // Fungsi hapus toko
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Toko'),
          content: const Text('Apakah Anda yakin ingin menghapus toko ini?'),
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
                try {
                  await TokoService().hapusToko(widget.tokoId);
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                } catch (e) {
                  print('Error deleting store: $e');
                  // Show error message to user
                }
              },
            ),
          ],
        );
      },
    );
  }
}
