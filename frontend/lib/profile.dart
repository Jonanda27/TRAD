import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trad/Model/RestAPI/service_profile.dart';
import 'package:trad/Provider/profile_provider.dart';
import 'package:trad/edit_profile.dart';
import 'package:trad/login.dart';
import 'pelayanan_poin.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isPickingImage = false;
  bool isAutoSubscribeEnabled = true;
  bool _isLoggingOut = false; // Flag to prevent multiple logouts

  Future<void> saveUserId(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('id', id);
    
    // Debugging: check if the value was stored correctly
    int? storedid = prefs.getInt('id');
    print('Stored id: $storedid');
  }

  Future<void> loadUserIdAndNavigate(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? id = prefs.getInt('id');
      
      if (id != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PelayananPoin()),
        );
      } else {
        print('User ID is null');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User ID not found, please log in again.')),
        );
      }
    } catch (e) {
      print('Error retrieving userId: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again.')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().fetchProfileData();
    });
  }

  Future<void> updateProfilePicture() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final String extension = pickedFile.path.split('.').last.toLowerCase();

      if (extension == 'png' || extension == 'jpeg' || extension == 'jpg') {
        try {
          final File imageFile = File(pickedFile.path);

          final SharedPreferences prefs = await SharedPreferences.getInstance();
          final int? userId = prefs.getInt('userId'); // Corrected key to 'userId'

          if (userId != null) {
            await ProfileService.updateProfilePicture(userId, imageFile.path);
            await context.read<ProfileProvider>().fetchProfileData();
          }
        } catch (e) {
          print('Error updating profile picture: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update profile picture. Please try again.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a PNG or JPEG image.')),
        );
      }
    }
  }

  Future<void> handleLogout() async {
    if (_isLoggingOut) return; // Prevent multiple logouts

    setState(() {
      _isLoggingOut = true;
    });

    try {
      await ProfileService.logout();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HalamanAwal()), // Replace with your login screen
      );
    } catch (e) {
      print('Error logging out: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed. Please try again.')),
      );
    } finally {
      setState(() {
        _isLoggingOut = false; // Reset the flag after logout attempt
      });
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
              title: Text('Profil Saya', style: TextStyle(color: Colors.white)),
              centerTitle: true,
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final profileData = profileProvider.profileData;

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
                            ? _getProfileImage(profileData['fotoProfil'])
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EditProfilePage()),
                      );
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
                  onTap: () async {
                    try {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      int? id = prefs.getInt('id');

                      if (id != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PelayananPoin()),
                        );
                      } else {
                        print('User ID is null');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('User ID not found, please log in again.')),
                        );
                      }
                    } catch (e) {
                      print('Error navigating to PelayananPoin: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to navigate. Please try again.')),
                      );
                    }
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
                    // Aksi untuk Profil Toko
                  },
                ),
                ListTile(
                  title: Text('Log Out', style: TextStyle(color: Colors.red)),
                  onTap: _isLoggingOut ? null : handleLogout, // Disable button during logout
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
