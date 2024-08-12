import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trad/Model/RestAPI/service_profile.dart';
import 'package:trad/Provider/profile_provider.dart';
import 'package:trad/Screen/HomeScreen/home_screen.dart';
import 'package:trad/edit_profile.dart';
import 'package:trad/login.dart';
import 'pelayanan_poin.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isAutoSubscribeEnabled = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().fetchProfileData();
    });
  }

  Future<void> updateProfilePicture() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      try {
        await context
            .read<ProfileProvider>()
            .updateProfile({'fotoProfil': image.path});
      } catch (e) {
        print('Error updating profile picture: $e');
        // Show error message to user
      }
    }
  }

  Future<void> handleLogout() async {
    try {
      await ProfileService.logout();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) =>
                HalamanAwal()), // Replace with your login screen
      );
    } catch (e) {
      print('Error logging out: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logout failed. Please try again.')),
      );
    }
  }

  ImageProvider? _getProfileImage(String base64String) {
    try {
      return MemoryImage(base64Decode(base64String));
    } catch (e) {
      print('Error decoding profile image: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        if (profileProvider.isLoading) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: const Color.fromRGBO(0, 84, 102, 1),
              title: const Text('Profil Saya',
                  style: TextStyle(color: Colors.white)),
              centerTitle: true,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final profileData = profileProvider.profileData;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color.fromRGBO(0, 84, 102, 1),
            title: const Text('Profil Saya',
                style: TextStyle(color: Colors.white)),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.white),
                onPressed: () {
                  // Action when notification icon is pressed
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
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
                            ? _getProfileImage(profileData['fotoProfil'])
                            : null,
                        child: profileData['fotoProfil'] == null
                            ? const Icon(Icons.person,
                                size: 40, color: Colors.white)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profileData['nama'] ?? 'Guest',
                          style: const TextStyle(
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
                const SizedBox(height: 16),
                Text('Subs : ${profileData['status'] ?? '-'}'),
                Text('Exp : ${profileData['expDate'] ?? '-'}'),
                Row(
                  children: [
                    const Icon(Icons.attach_money, color: Colors.black),
                    Text(profileData['tradvoucher'] ?? '-'),
                    const SizedBox(width: 16),
                    const Icon(Icons.attach_money, color: Colors.black),
                    Text(profileData['tradPoint'] ?? '-'),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EditProfilePage()),
                      );
                    },
                    child: const Text('Edit Akun'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(0, 84, 102, 1),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                ListTile(
                  title: const Text(
                    'Radar TRAD',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              'Level Radar TRAD : ${profileData['tradLevel'] ?? '-'}'),
                          ElevatedButton(
                            onPressed: () {
                              // Implement upgrade functionality
                            },
                            child: const Text('Upgrade'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF005466),
                              side: const BorderSide(color: Color(0xFF005466)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                ListTile(
                  title: const Text('Jumlah Referal'),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          'Target : ${profileData['targetRefProgress'] ?? '-'} / ${profileData['targetRefValue'] ?? '-'}'),
                      ElevatedButton(
                        onPressed: () {
                          // Implement referral functionality
                        },
                        child: const Text(
                          'Sebarkan Referal',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF005466),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Bonus Radar TRAD Bulan Ini'),
                TextField(
                  decoration: InputDecoration(
                    hintText: profileData['bonusRadarTradBulanIni'] ?? '0',
                    border: const OutlineInputBorder(),
                  ),
                  readOnly: true,
                ),
                const SizedBox(height: 8),
                const Text('max 1.000.000'),
                const Divider(),
                ListTile(
                  title: const Text('Bayar Subscribe Radar TRAD'),
                  onTap: () {
                    // Aksi untuk Bayar Subscribe
                  },
                ),
                ListTile(
                  title: const Text('Gift Sub'),
                  onTap: () {
                    // Aksi untuk Gift Sub
                  },
                ),
                ListTile(
                  title: const Text('Auto Subscribe Radar'),
                  trailing: Switch(
                    value: isAutoSubscribeEnabled,
                    onChanged: (value) {
                      setState(() {
                        isAutoSubscribeEnabled = value;
                      });
                    },
                    activeColor: const Color.fromRGBO(0, 84, 102, 1),
                  ),
                ),
                ListTile(
                  title: const Text('Layanan Poin dan lainnya'),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => PelayananPoin()),
                    );
                  },
                ),
                ListTile(
                  title: const Text('Riwayat Transaksi'),
                  onTap: () {
                    // Aksi untuk Riwayat Transaksi
                  },
                ),
                const Divider(),
                ListTile(
                  title: const Text('Fitur Lainnya',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    // Aksi untuk Fitur Lainnya
                  },
                ),
                ListTile(
                  title: const Text('Profil Toko'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  },
                ),
                ListTile(
                  title: const Text('Log Out',
                      style: TextStyle(color: Colors.red)),
                  onTap: handleLogout,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
