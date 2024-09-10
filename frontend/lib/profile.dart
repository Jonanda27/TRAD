import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trad/Model/RestAPI/service_profile.dart';
import 'package:trad/Provider/profile_provider.dart';
import 'package:trad/Screen/HomeScreen/home_screen.dart';
import 'package:trad/edit_profile.dart';
import 'package:trad/login.dart';
import 'package:trad/Screen/TokoScreen/profile_toko.dart';
import 'pelayanan_poin.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  
  bool isAutoSubscribeEnabled = true;
  bool _isLoggingOut = false;

Future<void> updateProfilePicture() async {
  final ImagePicker picker = ImagePicker();
  final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

  if (pickedFile != null) {
    final String extension = pickedFile.path.split('.').last.toLowerCase();

    if (extension == 'png' || extension == 'jpeg' || extension == 'jpg') {
      try {
        final File imageFile = File(pickedFile.path);

        // Cek ukuran file sebelum mengunggah (misalnya 5MB)
        if (await imageFile.length() > 5 * 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('File terlalu besar. Pilih gambar yang lebih kecil dari 5MB.')),
          );
          return;
        }

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final int? userId = prefs.getInt('userId'); 

        if (userId != null) {
          try {
            await ProfileService.updateProfilePicture(userId, imageFile.path);
            await context.read<ProfileProvider>().fetchProfileData();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Foto profil berhasil diperbarui.')),
            );
          } catch (e) {
            // Tangani kesalahan spesifik yang mungkin terjadi pada server atau API
            print('Error updating profile picture on server: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal memperbarui foto profil. Coba lagi.')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User ID tidak ditemukan. Mohon login kembali.')),
          );
        }
      } catch (e) {
        print('Error updating profile picture: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui foto profil. Coba lagi.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Silakan pilih gambar dengan format PNG atau JPEG.')),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tidak ada gambar yang dipilih.')),
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


  Future<void> handleLogout() async {
    if (_isLoggingOut) return;

    setState(() {
      _isLoggingOut = true;
    });

    try {
      await ProfileService.logout();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HalamanAwal()),
      );
    } catch (e) {
      print('Error logging out: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed. Please try again.')),
      );
    } finally {
      setState(() {
        _isLoggingOut = false;
      });
    }
  }


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().fetchProfileData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        if (profileProvider.isLoading) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final profileData = profileProvider.profileData;

        return Scaffold(
          body: Container(
            color: const Color(0xFF115E59), // Teal 700
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Profil Saya',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Icon(Icons.notifications, color: Colors.white),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          profileData['nama'] ?? 'Michael Desmond Limanto',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'Subs : ${profileData['status'] ?? 'AKTIF'} Exp : ${profileData['expDate'] ?? 'dd/mm/yyyy'}',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            _buildIconText('R', profileData['tradvoucher'] ?? '1.000.000.000', const Color(0xFF115E59)),
                                            const SizedBox(width: 16),
                                            _buildIconText('P', profileData['tradPoint'] ?? '1.000.000.000', Colors.blue),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              OutlinedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => EditProfilePage()),
                                  );
                                },
                                child: const Text('Edit Akun'),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(40),
                                  side: const BorderSide(color: Color(0xFF115E59)),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildCard(
                                title: 'Radar TRAD',
                                content: Column(
                                  children: [
                                    _buildRow(
                                      'Level Radar TRAD : ${profileData['tradLevel'] ?? '1'}',
                                      Row(
                                        children: [
                                          const SizedBox(width: 8),
                                          OutlinedButton(
                                            onPressed: () {
                                              // Implement upgrade functionality
                                            },
                                            child: const Text('Upgrade'),
                                            style: OutlinedButton.styleFrom(
                                              minimumSize: const Size(0, 30),
                                              padding: const EdgeInsets.symmetric(horizontal: 8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    _buildRow(
                                      'Jumlah Referal',
                                      Row(
                                        children: [
                                          Text('Target: ${profileData['targetRefProgress'] ?? '9'} / ${profileData['targetRefValue'] ?? '8'}',
                                              style: const TextStyle(fontWeight: FontWeight.bold)),
                                          TextButton(
                                            onPressed: () {
                                              // Implement referral functionality
                                            },
                                            child: const Text('Sebarkan Referal'),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text('Bonus Radar TRAD Bulan Ini'),
                                    const SizedBox(height: 4),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        profileData['bonusRadarTradBulanIni'] ?? '0',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const Align(
                                      alignment: Alignment.centerRight,
                                      child: Text('max 1.000.000', style: TextStyle(fontSize: 12)),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Adding your ListTile items
                              ListTile(
                                title: Text('Bayar'),
                                onTap: () {
                                  // Aksi untuk Bayar Subscribe
                                },
                                trailing: Icon(Icons.chevron_right),
                              ),
                              const SizedBox(height: 16),
                              // Adding your ListTile items
                              ListTile(
                                title: Text('Bayar Subscribe Radar TRAD'),
                                onTap: () {
                                  // Aksi untuk Bayar Subscribe
                                },
                                trailing: Icon(Icons.chevron_right),
                              ),
                              ListTile(
                                title: Text('Gift Sub'),
                                onTap: () {
                                  // Aksi untuk Gift Sub
                                },
                                trailing: Icon(Icons.chevron_right),
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
                                trailing: Icon(Icons.chevron_right),
                              ),
                              ListTile(
                                title: Text('Fitur Lainnya'),
                                onTap: () {
                                  // Aksi untuk Fitur Lainnya
                                },
                                trailing: Icon(Icons.chevron_right),
                              ),
                              ListTile(
                                title: Text('Profil Toko'),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => HomeScreen()),
                                  );
                                },
                                trailing: Icon(Icons.chevron_right),
                              ),
                              ListTile(
                                title: Text('Log Out'),
                                onTap: handleLogout,
                                trailing: _isLoggingOut
                                    ? SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Icon(Icons.exit_to_app),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIconText(String iconText, String value, Color iconBackgroundColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: iconBackgroundColor,
          ),
          child: Text(
            iconText,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 4),
        Text(value, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildCard({required String title, required Widget content}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, Widget trailing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        trailing,
      ],
    );
  }
}
