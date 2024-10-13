import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  String formatNumber(String number) {
    try {
      // Menghapus '.00' jika ada di akhir string
      if (number.contains('.') && number.endsWith('00')) {
        number = number.split('.')[0];
      }

      // Mengonversi string menjadi integer
      final parsedNumber = int.parse(number.replaceAll('.', ''));

      // Menggunakan NumberFormat untuk format angka
      return NumberFormat.decimalPattern('id').format(parsedNumber);
    } catch (e) {
      print('Error parsing number: $e'); // Menangani error parsing
      return number; // Kembalikan string asli jika gagal
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF005466), // Dark teal
        title: const Text('Profil Toko',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w400,
                color: Colors.white)),
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
          final List<dynamic>? operationalHours =
              profile['jam_operasional'] as List<dynamic>?;

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
              imageProvider = const AssetImage(
                  'assets/img/default_image.png'); // Use default image on error
            }
          } else {
            imageProvider = const AssetImage(
                'assets/img/default_image.png'); // Use default image when null or empty
          }

          // Jika data kota belum di-cache, ambil kota berdasarkan provinsi toko
          if (!_kotaCache.containsKey(provinsiId)) {
            _fetchCities(provinsiId);
          }

          final List<dynamic>? kategoriToko =
              profile['kategori_toko'] as List<dynamic>?;

          // Jika kategori_toko tidak null dan berisi data, tampilkan kategori, jika tidak tampilkan "Kategori tidak tersedia"
          String kategoriDisplay = "Kategori tidak tersedia";
          if (kategoriToko != null && kategoriToko.isNotEmpty) {
            kategoriDisplay =
                kategoriToko.map((item) => item['kategori']).join(', ');
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
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: Colors
                              .grey.shade200, // Placeholder image background
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Container(
                          width: 200.0,
                          height: 200.0,
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
                              style: const TextStyle(
                                  color: Color(0xFFD1D5DB), fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              profile['alamatToko'] ?? 'Alamat tidak tersedia',
                              style: const TextStyle(
                                  color: Color(0xFF212121), fontSize: 12),
                            ),
                            // Menambahkan tampilan provinsi dan kota toko
                            Text(
                              'Kota: ${_getKotaName(kotaId, provinsiId)}, ${_getProvinsiName(provinsiId)}',
                              style: const TextStyle(
                                  color: Color(0xFF212121), fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.phone,
                                    color: Color(0xFF005466), size: 14),
                                const SizedBox(width: 4),
                                Text(
                                    profile['nomorTeleponToko'] ??
                                        'Telepon tidak tersedia',
                                    style: const TextStyle(
                                        color: Color(0xFF005466),
                                        fontSize: 12)),
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
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: buildInfoColumnWithLeftIcon(
                          Icons.wallet,
                          'Saldo Poin Toko',
                          formatNumber(profile['tradPoint']?.toString() ?? '0'),
                        ),
                      ),
                      const SizedBox(width: 32), // Jarak horizontal sebesar 40
                      Expanded(
                        child: buildInfoColumnWithLeftIcon(
                          Icons.local_offer,
                          'Rentang Voucher',
                          profile['voucherToko'] ?? 'N/A',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Product Count and Bank Account Info
                // Product Count and Bank Account Info
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
                                builder: (context) =>
                                    ListProduk(id: widget.tokoId),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(
                          width: 32), // Add some spacing between columns
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
                                bankName: profile['namaBank'],
                                accountNumber: profile['nomorRekening'],
                                accountHolder: profile['pemilikRekening'],
                                onEdit: () {
                                  // Logic for deciding whether to show Add or Edit dialog
                                  if (profile['namaBank'] == null ||
                                      profile['namaBank'].isEmpty ||
                                      profile['nomorRekening'] == null ||
                                      profile['nomorRekening'].isEmpty ||
                                      profile['pemilikRekening'] == null ||
                                      profile['pemilikRekening'].isEmpty) {
                                    _showAddBankAccountDialog();
                                  } else {
                                    _showEditBankAccountDialog(
                                      selectedBank: profile['namaBank'],
                                      accountNumber: profile['nomorRekening'],
                                      accountHolder: profile['pemilikRekening'],
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
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
                            Icon(Icons.access_time,
                                color: Colors.grey.shade800),
                            const SizedBox(width: 8),
                            Text(
                              'Jam Operasional',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey.shade800),
                            ),
                            Icon(
                                isExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: Colors.grey.shade800),
                          ],
                        ),
                      ),
                      if (isExpanded && operationalHours != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 24.0, top: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: operationalHours.map((item) {
                              if (item['statusBuka'] == 1) {
                                return Text(
                                  '${item['hari']} ${item['jamBuka']}–${item['jamTutup']}',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade800),
                                );
                              } else {
                                return SizedBox
                                    .shrink(); // This will not display anything if statusBuka is not 1
                              }
                            }).toList(),
                          ),
                        )
                      // Padding(
                      //   padding: const EdgeInsets.only(left: 24.0, top: 8.0),
                      //   child: Column(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: operationalHours.map((item) {
                      //       return Text(
                      //         '${item['hari']} ${item['jamBuka']}–${item['jamTutup']}',
                      //         style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
                      //       );
                      //     }).toList(),
                      //   ),
                      // )
                      else if (isExpanded)
                        Padding(
                          padding: const EdgeInsets.only(left: 24.0, top: 8.0),
                          child: Text(
                            'Jam operasional tidak tersedia',
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey.shade800),
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
                Divider(),
                ListTile(
                  title: const Text('Hapus Toko',
                      style: TextStyle(color: Colors.red)),
                  onTap: () => _showDeleteConfirmation(context),
                ),

                const SizedBox(height: 16),

                // Point Services Section
                buildSectionTitle('Layanan Poin dan lainnya'),
                buildMenuItem('Pencairan Poin Toko', Icons.money, onTap: () {}),
                Divider(),
                buildMenuItem('Jual Subscription TRAD', Icons.subscriptions,
                    onTap: () {}),
                Divider(),
                buildMenuItem('Pusat Bantuan TRAD Care', Icons.help_center,
                    onTap: () {}),
                Divider(),
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

  Widget buildInfoColumnWithLeftIcon(
    IconData icon,
    String value,
    String title, {
    bool isEditable = false,
    VoidCallback? onEdit, // Named parameter added
    String? bankName,
    String? accountNumber,
    String? accountHolder,
  }) {
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
                if (isEditable && onEdit != null) ...[
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap:
                        onEdit, // This will call the function passed in the onEdit parameter
                    child: Icon(Icons.edit_square,
                        size: 16, color: Colors.teal.shade800),
                  ),
                ]
              ],
            ),
          ],
        ),
      ],
    );
  }

  void _showEditBankAccountDialog({
    required String selectedBank,
    required String accountNumber,
    required String accountHolder,
  }) {
    TextEditingController accountNumberController =
        TextEditingController(text: accountNumber);
    TextEditingController accountHolderNameController =
        TextEditingController(text: accountHolder);
    String? bank = selectedBank;

    // List of bank options
    List<String> bankOptions = ['BCA', 'BRI', 'BNI'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6, // 60% of screen height
          maxChildSize: 0.9, // Can be stretched up to 90% of screen height
          minChildSize: 0.4, // Minimum 40% of screen height
          builder: (BuildContext context, ScrollController scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                children: [
                  // Modal Header
                  Center(
                    child: Container(
                      height: 5,
                      width: 40,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  // Title
                  const Text(
                    'Edit Rekening Toko',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // Form for editing bank details
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6), // Rounded corners
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start, // Align text to the left
                      children: [
                        // Dropdown for Bank
                        const Text(
                          'Nama Bank',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: bank,
                          items: bankOptions.map((String bank) {
                            return DropdownMenuItem<String>(
                              value: bank,
                              child: Text(bank),
                            );
                          }).toList(),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              bank = newValue;
                            });
                          },
                          hint: const Text('Pilih Bank'),
                        ),
                        const SizedBox(height: 16),
                        // Nomor Rekening Field
                        const Text(
                          'Nomor Rekening',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: accountNumberController,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        // Nama Pemilik Rekening Field
                        const Text(
                          'Nama Pemilik Rekening',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: accountHolderNameController,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the modal
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 24),
                        ),
                        child: const Text('Batal',
                            style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton(
                        onPressed: () async {
                          // Validate fields
                          String nomorRekening =
                              accountNumberController.text.trim();
                          String pemilikRekening =
                              accountHolderNameController.text.trim();

                          if (bank == null ||
                              nomorRekening.isEmpty ||
                              pemilikRekening.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Semua kolom harus diisi')),
                            );
                            return;
                          }

                          // Call ubahBankToko service
                          Map<String, dynamic> result =
                              await TokoService().ubahBankToko(
                            tokoId: widget.tokoId,
                            namaBank: bank!,
                            nomorRekening: nomorRekening,
                            pemilikRekening: pemilikRekening,
                          );

                          if (result['status'] == 'success') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(result['message'])),
                            );
                            Navigator.of(context).pop(); // Close the dialog
                            setState(() {
                              _profileData = TokoService().profileToko(
                                  widget.tokoId); // Refresh the profile data
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(result['message'])),
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.teal),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 24),
                        ),
                        child: const Text('Simpan',
                            style: TextStyle(color: Colors.teal)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddBankAccountDialog() {
    TextEditingController accountNumberController = TextEditingController();
    TextEditingController accountHolderNameController = TextEditingController();
    String? selectedBank; // To store selected bank value

    // List of bank options
    List<String> bankOptions = ['BCA', 'BRI', 'BNI'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6, // 60% of screen height
          maxChildSize: 0.9, // Can be stretched up to 90% of screen height
          minChildSize: 0.4, // Minimum 40% of screen height
          builder: (BuildContext context, ScrollController scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                children: [
                  // Handle to show modal can be dragged
                  Center(
                    child: Container(
                      height: 5,
                      width: 40,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  // Title
                  const Text(
                    'Tambah Rekening Toko',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // Form container with rounded corners
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6), // Rounded corners
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start, // Align text to the left
                      children: [
                        // Label for Nama Bank
                        const Text(
                          'Nama Bank',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        // Dropdown for selecting Bank
                        DropdownButtonFormField<String>(
                          value: selectedBank,
                          items: bankOptions.map((String bank) {
                            return DropdownMenuItem<String>(
                              value: bank,
                              child: Text(bank),
                            );
                          }).toList(),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedBank = newValue; // Set the selected bank
                            });
                          },
                          hint: const Text('Pilih Bank'),
                        ),
                        const SizedBox(height: 16),
                        // Label for Nomor Rekening
                        const Text(
                          'Nomor Rekening',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        // Nomor Rekening Field
                        TextFormField(
                          controller: accountNumberController,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        // Label for Nama Pemilik Rekening
                        const Text(
                          'Nama Pemilik Rekening',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        // Nama Pemilik Rekening Field
                        TextFormField(
                          controller: accountHolderNameController,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment
                        .center, // Center the buttons horizontally
                    children: [
                      // "Batal" button styled like "Tidak" (red background)
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pop(); // Close the modal when "Batal" is pressed
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.red, // Red background for "Batal"
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                6), // Rounded corners with radius 6
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 24), // Padding for better button size
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(
                            color: Colors.white, // White text color for "Batal"
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(
                          width:
                              16), // Spacing between "Batal" and "Simpan" buttons
                      // "Simpan" button styled like "Ya" (teal outline)
                      OutlinedButton(
                        onPressed: () async {
                          String nomorRekening =
                              accountNumberController.text.trim();
                          String pemilikRekening =
                              accountHolderNameController.text.trim();

                          if (selectedBank == null ||
                              nomorRekening.isEmpty ||
                              pemilikRekening.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Semua kolom harus diisi')),
                            );
                            return;
                          }

                          // Call the tambahBankToko service from service_toko.dart
                          Map<String, dynamic> result =
                              await TokoService().tambahBankToko(
                            tokoId: widget.tokoId,
                            namaBank: selectedBank!,
                            nomorRekening: nomorRekening,
                            pemilikRekening: pemilikRekening,
                          );

                          if (result['status'] == 'success') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(result['message'])),
                            );
                            Navigator.of(context).pop();
                            setState(() {
                              _profileData =
                                  TokoService().profileToko(widget.tokoId);
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(result['message'])),
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                              color: Colors
                                  .teal), // Teal border color for "Simpan"
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                6), // Rounded corners with radius 6
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 24), // Padding for better button size
                        ),
                        child: const Text(
                          'Simpan',
                          style: TextStyle(
                            color: Colors.teal, // Teal text color for "Simpan"
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget buildSectionTitle(String title) {
    return Container(
      color: Color(0xFFDBE7E4),
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

  Widget buildMenuItem(String title, IconData icon,
      {required VoidCallback onTap, bool isDelete = false}) {
    return ListTile(
      title: Text(title,
          style: TextStyle(color: isDelete ? Colors.red : Colors.black)),
      onTap: onTap,
      trailing: Icon(Icons.chevron_right,
          color: Colors.grey.shade600), // Grey chevron arrow
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
