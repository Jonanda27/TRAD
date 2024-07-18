import 'package:flutter/material.dart';
import 'package:trad/edit_info_profile.dart'; // Pastikan file ini diimport
import 'package:trad/edit_info_pribadi.dart';
import 'package:trad/ubah_pin.dart';
import 'package:trad/ubah_sandi.dart';

class EditProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Akun',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF005466),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey[300],
              child: IconButton(
                icon: Icon(Icons.camera_alt),
                onPressed: () {
                  // Add image upload functionality
                },
              ),
            ),
            Divider(),
            SizedBox(height: 20),
            buildSectionTitle('Info Profil', context, true),
            buildProfileInfoRow('Nama', 'Michael Desmond Limanto'),
            buildProfileInfoRow('User ID', 'macdeli'),
            Divider(),
            SizedBox(height: 20),
            buildSectionTitle('Info Pribadi', context, true),
            buildPersonalInfoRow('E-mail', 'mike@gmail.com'),
            buildPersonalInfoRow('Nomor HP', '0812345678'),
            buildPersonalInfoRow('Tanggal Lahir', '01 Januari 2000'),
            buildPersonalInfoRow('Jenis Kelamin', 'Pria'),
            SizedBox(height: 20),
            buildSectionTitle('Keamanan', context, false),
            buildSecurityOption('Ubah Kata Sandi', () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => UbahSandiPage()),
              );
            }),
            buildSecurityOption('Ubah PIN', () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => UbahPinPage()),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget buildSectionTitle(
      String title, BuildContext context, bool showEditIcon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (showEditIcon)
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              if (title == 'Info Profil') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditInfoProfilePage()),
                );
              }

              if (title == 'Info Pribadi') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditInfoPribadiPage()),
                );
              }
              // Tambahkan else if di sini jika Anda ingin menavigasi ke halaman lain untuk bagian lainnya
            },
          ),
      ],
    );
  }

  Widget buildProfileInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0), // Adjusted for closer spacing
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(value),
        ],
      ),
    );
  }

  Widget buildPersonalInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0), // Adjusted for closer spacing
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(value),
        ],
      ),
    );
  }

  Widget buildSecurityOption(String title, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onPressed,
            child: Text(
              title,
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}
