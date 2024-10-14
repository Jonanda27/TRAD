import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trad/Model/RestAPI/service_home.dart';
import 'package:trad/Model/RestAPI/service_profile.dart';
import 'package:trad/Provider/profile_provider.dart';
import 'package:trad/Screen/AuthScreen/Login/login.dart';
import 'package:trad/Screen/BayarScreen/bayar_screen.dart';
import 'package:trad/Screen/HomeScreen/home_screen.dart';
import 'package:trad/Screen/ProfileScreen/edit_profile.dart';
import 'package:trad/Screen/ProfileScreen/pelayanan_poin.dart';
import 'package:trad/Screen/BayarScreen/riwayat_transaksi_pembeli.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final String extension = pickedFile.path.split('.').last.toLowerCase();

      if (extension == 'png' || extension == 'jpeg' || extension == 'jpg') {
        try {
          final File imageFile = File(pickedFile.path);

          // Cek ukuran file sebelum mengunggah (misalnya 5MB)
          if (await imageFile.length() > 5 * 1024 * 1024) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      'File terlalu besar. Pilih gambar yang lebih kecil dari 5MB.')),
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
                SnackBar(
                    content: Text('Gagal memperbarui foto profil. Coba lagi.')),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text('User ID tidak ditemukan. Mohon login kembali.')),
            );
          }
        } catch (e) {
          print('Error updating profile picture: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Gagal memperbarui foto profil. Coba lagi.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Silakan pilih gambar dengan format PNG atau JPEG.')),
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

  Future<void> _switchRole() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('id');
    if (userId != null) {
      try {
        await HomeService().gantiRole(userId);
        // Navigate to HomeScreen after switching role
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } catch (e) {
        print('Error switching role: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal beralih peran. Silakan coba lagi.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User ID tidak ditemukan.')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().fetchProfileData(forceRefresh: true);
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
            color: Color.fromARGB(255, 0, 84, 102), // Teal 700
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
                                      backgroundImage:
                                          profileData['fotoProfil'] != null
                                              ? _getProfileImage(
                                                  profileData['fotoProfil'])
                                              : null,
                                      child: profileData['fotoProfil'] == null
                                          ? Icon(Icons.person,
                                              size: 40, color: Colors.white)
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          profileData['nama'] ??
                                              'Michael Desmond Limanto',
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
                                            Container(
  padding: EdgeInsets.only(
    top: 8,
    bottom: 8,
    left: 0,
    right: 0
  ),
  child: SvgPicture.asset(
    'assets/svg/icons/icons-voucher.svg',
    width: 22,
    height: 22,
    color: const Color(0xFF115E59),
  ),
),
Text(
  NumberFormat('#,##0.00', 'id_ID').format(double.parse(profileData['tradvoucher'] ?? '0')),
  style: const TextStyle(fontSize: 14)
),
const SizedBox(width: 16),
_buildIconText(
  'P',
  profileData['tradPoint'] ?? '1.000.000.000',
  const Color(0xFF115E59)
),

                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: EdgeInsets.only(
                                  top: 0,
                                  bottom: 0,
                                  left:
                                      MediaQuery.of(context).size.width * 0.225,
                                  right: MediaQuery.of(context).size.width * 0,
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              EditProfilePage()),
                                    );
                                  },
                                  child: Text(
                                    'Edit Akun',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    maxLines: 1,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF115E59),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Padding(
                                padding: EdgeInsets.only(
                                  top: 0,
                                  bottom: 0,
                                  left:
                                      MediaQuery.of(context).size.width * 0.04,
                                  right:
                                      MediaQuery.of(context).size.width * 0.04,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Radar TRAD',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        top: 0,
                                        bottom: 0,
                                        left:
                                            MediaQuery.of(context).size.width *
                                                0.01,
                                        right:
                                            MediaQuery.of(context).size.width *
                                                0.01,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                                    child: const Text(
                                                      'Upgrade',
                                                      style: TextStyle(
                                                          color: Color(
                                                              0xFF115E59)),
                                                    ),
                                                    style: ButtonStyle(
                                                        maximumSize:
                                                            MaterialStateProperty.all<Size>(
                                                                const Size(
                                                                    110, 30)),
                                                        minimumSize: MaterialStateProperty.all<Size>(
                                                            const Size(0, 20)),
                                                        shape: MaterialStateProperty.all<
                                                                RoundedRectangleBorder>(
                                                            RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(6.0),
                                                                side: BorderSide(color: Color(0xFF115E59)))))),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          _buildRow(
                                            'Jumlah Referal  ',
                                            const Row(
                                              children: [
                                                Icon(
                                                  Icons.info_outlined,
                                                  size: 18,
                                                  color: Colors.grey,
                                                )
                                              ],
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text('Target: '),
                                              Text(
                                                  '${profileData['targetRefProgress'] ?? '9'} / ${profileData['targetRefValue'] ?? '8'}  ',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              const Icon(
                                                Icons.shortcut,
                                                color: Color(0xFF115E59),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Clipboard.setData(ClipboardData(text: profileData['referralCode']));
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('Kode referal disalin: ${profileData['referralCode']}')),
                                                  );
                                                },
                                                child: const Text(
                                                  'Sebarkan Referal',
                                                  style: TextStyle(color: Color(0xFF115E59)),
                                                ),
                                              ),

                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(children: [
                                            Text('Bonus Radar TRAD Bulan Ini',
                                                textAlign: TextAlign.left),
                                            SizedBox(width: 4),
                                            Icon(Icons.info_outlined,
                                                size: 18, color: Colors.grey)
                                          ]),
                                          const SizedBox(height: 4),
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.grey[300]!,
                                              ),
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              profileData[
                                                      'bonusRadarTradBulanIni'] ??
                                                  '0',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          const Align(
                                            alignment: Alignment.centerRight,
                                            child: Text('max 1.000.000',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Adding your ListTile items
                              Padding(
                                padding: EdgeInsets.only(
                                  top: 0,
                                  bottom: 0,
                                  left:
                                      MediaQuery.of(context).size.width * 0.039,
                                  right:
                                      MediaQuery.of(context).size.width * 0.039,
                                ),
                                child: Divider(
                                    thickness: 1, color: Colors.grey[300]),
                              ),
                              ListTile(
                                title: Text('Bayar Subscribe Radar TRAD'),
                                onTap: () {
                                  // Aksi untuk Bayar Subscribe
                                },
                                // trailing: Icon(Icons.chevron_right),
                              ),
                              ListTile(
                                title: Text('Gift Sub'),
                                onTap: () {
                                  // Aksi untuk Gift Sub
                                },
                                // trailing: Icon(Icons.chevron_right),
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
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    int? id = prefs.getInt('id');

                                    if (id != null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                PelayananPoin()),
                                      );
                                    } else {
                                      print('User ID is null');
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'User ID not found, please log in again.')),
                                      );
                                    }
                                  } catch (e) {
                                    print(
                                        'Error navigating to PelayananPoin: $e');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Failed to navigate. Please try again.')),
                                    );
                                  }
                                },
                              ),
                              ListTile(
  title: Text('Riwayat Transaksi'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RiwayatTransaksiPembeli(idUser: profileData['id'])),
    );
  },
),

                              if (profileData['role'] == 'Pembeli') ...[
                                ListTile(
                                  title: Text(
                                    'Beralih ke Merchant',
                                    style: TextStyle(
                                      color: Color(
                                          0xFF005466), // Menggunakan warna #005466
                                      fontWeight: FontWeight.bold, // Teks bold
                                    ),
                                  ),
                                  onTap: _switchRole,
                                ),
                              ] else if (profileData['role'] == 'Penjual') ...[
                                ListTile(
                                  title: Text(
                                    'Beralih ke Customer',
                                    style: TextStyle(
                                      color: Color(
                                          0xFF005466), // Menggunakan warna #005466
                                      fontWeight: FontWeight.bold, // Teks bold
                                    ),
                                  ),
                                  onTap: () async {
                                    await _switchRole();
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ProfileScreen()),
                                    );
                                  },
                                ),
                              ],
                              Padding(
                                padding: EdgeInsets.only(
                                  top: 0,
                                  bottom: 0,
                                  left:
                                      MediaQuery.of(context).size.width * 0.039,
                                  right:
                                      MediaQuery.of(context).size.width * 0.039,
                                ),
                                child: Divider(
                                    thickness: 1, color: Colors.grey[300]),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  top: 0,
                                  bottom: 0,
                                  left:
                                      MediaQuery.of(context).size.width * 0.04,
                                  right:
                                      MediaQuery.of(context).size.width * 0.04,
                                ),
                                child: Text(
                                  'Fitur Lainnya',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 0, 84, 102),
                                  ),
                                ),
                              ),
                              if (profileData['role'] ==
                                  'Pembeli') // Hanya tampil jika role adalah Pembeli
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: 0,
                                    bottom: 0,
                                    left: MediaQuery.of(context).size.width *
                                        0.01,
                                    right: MediaQuery.of(context).size.width *
                                        0.01,
                                  ),
                                  child: Column(
                                    children: [
                                      ListTile(
                                        title: Text('Bayar'),
                                        onTap: () async {
                                          SharedPreferences prefs =
                                              await SharedPreferences
                                                  .getInstance();
                                          int? id = prefs.getInt('id');

                                          if (id != null) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    BayarScreen(userId: id),
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'User ID tidak ditemukan. Mohon login kembali.')),
                                            );
                                          }
                                        },
                                        // trailing: Icon(Icons.chevron_right),
                                      ),
                                    ],
                                  ),
                                ),
Padding(
  padding: EdgeInsets.only(
    top: 0,
    bottom: 0,
    left: MediaQuery.of(context).size.width * 0.01,
    right: MediaQuery.of(context).size.width * 0.01,
  ),
  child: Column(
    children: [
      if (profileData['role'] == 'Penjual')
        ListTile(
          title: Text('Profil Toko'),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
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

  Widget _buildIconText(
      String iconText, String value, Color iconBackgroundColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: iconBackgroundColor,
          ),
          child: Text(iconText,
              style: const TextStyle(fontSize: 10, color: Colors.white)),
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
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        trailing,
      ],
    );
  }
}
