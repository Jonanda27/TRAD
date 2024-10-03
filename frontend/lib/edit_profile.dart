import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trad/Provider/profile_provider.dart';
import 'package:trad/edit_info_profile.dart';
import 'package:trad/edit_info_pribadi.dart';
import 'package:trad/ubah_pin.dart';
import 'package:trad/ubah_sandi.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:trad/Model/RestAPI/service_profile.dart'; // Ensure this import

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);
      try {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final int? userId = prefs.getInt('id');
        if (userId != null) {
          await ProfileService.updateProfilePicture(userId, imageFile.path);
          await Provider.of<ProfileProvider>(context, listen: false).fetchProfileData();
        }
      } catch (e) {
        print('Error updating profile picture: $e');
      }
    }
  }
  
@override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        final profileData = profileProvider.profileData;

        return Scaffold(
          backgroundColor: Colors.white,
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
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: profileData['fotoProfil'] != null
                          ? MemoryImage(base64Decode(profileData['fotoProfil']))
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(Icons.camera_alt, color: Color(0xFF005466)),
                          onPressed: _pickImage,
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(),
                SizedBox(height: 20),
                buildSectionTitle('Info Profil', context, true),
                buildProfileInfoRow('Nama', profileData['nama'] ?? ''),
                buildProfileInfoRow('User ID', profileData['userId'] ?? ''),
                Divider(),
                SizedBox(height: 20),
                buildSectionTitle('Info Pribadi', context, true),
                buildPersonalInfoRow('E-mail', profileData['email'] ?? ''),
                buildPersonalInfoRow('Nomor HP', profileData['noHp'] ?? ''),
                buildPersonalInfoRow('Tanggal Lahir', profileData['tanggalLahir'] ?? ''),
                buildPersonalInfoRow('Jenis Kelamin', profileData['jenisKelamin'] ?? ''),
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
      },
    );
  }

  Widget buildSectionTitle(String title, BuildContext context, bool showEditIcon) {
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
              try {
                if (title == 'Info Profil') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditInfoProfilePage()),
                  );
                } else if (title == 'Info Pribadi') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditInfoPribadiPage()),
                  );
                }
              } catch (e) {
                print('Error navigating to edit page: $e');
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Error'),
                    content: Text('An error occurred while navigating: $e'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
      ],
    );
  }

  Widget buildProfileInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
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
      padding: const EdgeInsets.symmetric(vertical: 4.0),
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
