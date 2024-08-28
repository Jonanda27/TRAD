import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trad/Model/RestAPI/service_toko.dart';

class ProfileTokoScreen extends StatefulWidget {
  final int tokoId;

  ProfileTokoScreen({required this.tokoId});

  @override
  _ProfileTokoScreenState createState() => _ProfileTokoScreenState();
}

class _ProfileTokoScreenState extends State<ProfileTokoScreen> {
  late Future<Map<String, dynamic>> _profileData;
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    _profileData = TokoService().profileToko(widget.tokoId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF06444A), // Dark teal
        title: Text('Profil Toko', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.share, color: Colors.white),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return Center(child: Text('Data tidak tersedia'));
          }

          final profile = snapshot.data!['profileData'];
          // final bank = snapshot.data!['bank'];

          // Get operational hours as a list instead of a map
          final List<dynamic>? operationalHours = profile['jamOperasional'] as List<dynamic>?;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section with Store Information
                Container(
                  padding: EdgeInsets.all(16),
                  color: Colors.white, // White background
                  child: Row(
                    children: [
                      // Store image placeholder
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200, // Placeholder image background
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.store_mall_directory, size: 50, color: Colors.grey),
                      ),
                      SizedBox(width: 16),
                      // Store details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile['namaToko'] ?? 'Nama tidak tersedia',
                              style: TextStyle(
                                color: Color(0xFF06444A),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Makanan & Minuman',
                              style: TextStyle(color: Color.fromARGB(179, 52, 50, 50), fontSize: 14),
                            ),
                            SizedBox(height: 8),
                            Text(
                              profile['alamatToko'] ?? 'Alamat tidak tersedia',
                              style: TextStyle(color: Color.fromARGB(179, 0, 0, 0), fontSize: 12),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.phone, color: Color(0xFF06444A), size: 14),
                                SizedBox(width: 4),
                                Text(profile['nomorTeleponToko'] ?? 'Telepon tidak tersedia',
                                    style: TextStyle(color: Color(0xFF06444A), fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // Point and Voucher Info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buildInfoColumnWithLeftIcon(Icons.wallet, profile['saldoPoinToko']?.toString() ?? 'N/A', 'Saldo Poin Toko',),
                      buildInfoColumnWithLeftIcon(Icons.local_offer, profile['voucherToko'] ?? 'N/A', 'Rentang Voucher',),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // Product Count and Bank Account Info
                Padding(
  padding: const EdgeInsets.symmetric(horizontal: 12.0),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: buildInfoColumnWithLeftIcon(
          Icons.inventory, 
          
          profile['jumlahProduk']?.toString() ?? '0', isEditable: true ,
          'Jumlah Produk', 
        ),
      ),
      SizedBox(width: 8.0), // Add some spacing between columns
      Expanded(
  child: SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
    children: [
      buildInfoColumnWithLeftIcon(
        Icons.account_balance,
        '${profile['namaBank'] ?? 'Bank tidak tersedia'} - ${profile['nomorRekening'] ?? 'Nomor tidak tersedia'}',
        'Rekening Toko',
        isEditable: true,
      ),
    ],
  ),
        )
  )],
                  ),
                ),
                SizedBox(height: 16),

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
                            SizedBox(width: 8),
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
                SizedBox(height: 24),

                // Store Settings Section
                buildSectionTitle('Pengaturan Toko'),
                buildMenuItem('Edit Toko', Icons.edit, onTap: () {}),
                buildMenuItem('Hapus Toko', Icons.delete, onTap: () {}, isDelete: true),
                SizedBox(height: 16),

                // Point Services Section
                buildSectionTitle('Layanan Poin dan lainnya'),
                buildMenuItem('Pencairan Poin Toko', Icons.money, onTap: () {}),
                buildMenuItem('Jual Subscription TRAD', Icons.subscriptions, onTap: () {}),
                buildMenuItem('Pusat Bantuan TRAD Care', Icons.help_center, onTap: () {}),
                SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildInfoColumnWithLeftIcon(IconData icon, String title, String value, {bool isEditable = false}) {
    return Row(
      children: [
        Icon(icon, color: Colors.teal.shade800, size: 30), // Dark teal icons
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isEditable) ...[
                  SizedBox(width: 4),
                  Icon(Icons.edit, size: 16, color: Colors.grey.shade600), // Small pen edit icon
                ]
              ],
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildSectionTitle(String title) {
    return Container(
      color: Colors.grey.shade200,
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
      leading: Icon(icon, color: isDelete ? Colors.red : Colors.teal.shade800), // Dark teal or red icon
      title: Text(title, style: TextStyle(color: isDelete ? Colors.red : Colors.black)),
      onTap: onTap,
      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade600), // Grey chevron arrow
    );
  }
}
