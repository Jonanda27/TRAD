import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trad/Model/RestAPI/service_profile.dart';
import 'package:trad/Screen/HomeScreen/home_screen.dart';
import 'pelayanan_poin.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isAutoSubscribeEnabled = true;
  Map<String, dynamic> profileData = {};
  bool isLoading = true;
  int? id = 0;  // Added userId

    @override
  void initState() {
    super.initState();
    loadUserIdAndFetchProfileData();
  }

  Future<void> loadUserIdAndFetchProfileData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    id = prefs.getInt('id');
    print('User ID: $id');  // Add this line
    if (id != null) {
      await fetchProfileData();
    } else {
      setState(() {
        isLoading = false;
      });
      print('Error: userId not found in SharedPreferences');
    }
  }


  Future<void> fetchProfileData() async {
    try {
      final data = await ProfileService.fetchProfileData(id!);  // Used userId
      setState(() {
        profileData = data;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching profile data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateProfilePicture() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      try {
        await ProfileService.updateProfilePicture(id!, image.path);  // Used userId
        // Refresh profile data after updating picture
        await fetchProfileData();
      } catch (e) {
        print('Error updating profile picture: $e');
        // Show error message to user
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(0, 84, 102, 1),
          title: Text('Profil Saya', style: TextStyle(color: Colors.white)),
          centerTitle: true,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(0, 84, 102, 1),
        title: Text('Profil Saya', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // Action when notification icon is pressed
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: updateProfilePicture,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: profileData['fotoProfil'] != null
                        ? MemoryImage(base64Decode(profileData['fotoProfil']))
                        : null,
                    child: profileData['fotoProfil'] == null
                        ? Icon(Icons.person, size: 40, color: Colors.white)
                        : null,
                  ),
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profileData['nama'] ?? 'Guest',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('Email: ${profileData['email'] ?? '-'}'),
                    Text('Phone: ${profileData['noHp'] ?? '-'}'),
                    Text('Role: ${profileData['role'] ?? '-'}'),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            Text('Subs : ${profileData['status'] ?? '-'}'),
            Text('Exp : ${profileData['expDate'] ?? '-'}'),
            Row(
              children: [
                Icon(Icons.attach_money, color: Colors.black),
                Text(profileData['tradvoucher'] ?? '-'),
                SizedBox(width: 16),
                Icon(Icons.attach_money, color: Colors.black),
                Text(profileData['tradPoint'] ?? '-'),
              ],
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Implement edit account functionality
                },
                child: Text('Edit Akun'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(0, 84, 102, 1),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 16),
            Divider(),
            ListTile(
              title: Text(
                'Radar TRAD',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Level Radar TRAD : ${profileData['tradLevel'] ?? '-'}'),
                      ElevatedButton(
                        onPressed: () {
                          // Implement upgrade functionality
                        },
                        child: Text('Upgrade'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Color(0xFF005466),
                          side: BorderSide(color: Color(0xFF005466)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Divider(),
            ListTile(
              title: Text('Jumlah Referal'),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Target : ${profileData['targetRefProgress'] ?? '-'} / ${profileData['targetRefValue'] ?? '-'}'),
                  ElevatedButton(
                    onPressed: () {
                      // Implement referral functionality
                    },
                    child: Text(
                      'Sebarkan Referal',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF005466),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 16),
            Text('Bonus Radar TRAD Bulan Ini'),
            TextField(
              decoration: InputDecoration(
                hintText: profileData['bonusRadarTradBulanIni'] ?? '0',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
            ),
            SizedBox(height: 8),
            Text('max 1.000.000'),
            Divider(),
            ListTile(
              title: Text('Bayar Subscribe Radar TRAD'),
              onTap: () {
                // Aksi untuk Bayar Subscribe
              },
            ),
            ListTile(
              title: Text('Gift Sub'),
              onTap: () {
                // Aksi untuk Gift Sub
              },
            ),
            ListTile(
              title: Text('Auto Subscribe Radar'),
              trailing: Switch(
                value: isAutoSubscribeEnabled,
                onChanged: (value) {
                  setState(() {
                    isAutoSubscribeEnabled = value;
                  });
                },
                activeColor: Color.fromRGBO(0, 84, 102, 1),
              ),
            ),
            ListTile(
              title: Text('Layanan Poin dan lainnya'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => PelayananPoin()),
                );
              },
            ),
            ListTile(
              title: Text('Riwayat Transaksi'),
              onTap: () {
                // Aksi untuk Riwayat Transaksi
              },
            ),
            Divider(),
            ListTile(
              title: Text('Fitur Lainnya',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                // Aksi untuk Fitur Lainnya
              },
            ),
            ListTile(
              title: Text('Profil Toko'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  HomeScreen()),
                );
              },
            ),
            ListTile(
              title: Text('Log Out', style: TextStyle(color: Colors.red)),
              onTap: () {
                // Aksi untuk Log Out
              },
            ),
          ],
        ),
      ),
    );
  }
}
