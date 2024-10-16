import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trad/Provider/profile_provider.dart';
import 'package:trad/utility/text_opensans.dart';
import 'package:trad/utility/warna.dart';
import 'package:trad/widget/component/costume_teksfield3.dart';

class EditInfoProfilePage extends StatefulWidget {
  @override
  _EditInfoProfilePageState createState() => _EditInfoProfilePageState();
}

class _EditInfoProfilePageState extends State<EditInfoProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _userIDController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final profileData = context.read<ProfileProvider>().profileData;
    _nameController.text = profileData['nama'] ?? '';
    _userIDController.text = profileData['userId'] ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _userIDController.dispose();
    super.dispose();
  }

  String? validateField(String? value, String fieldName) {
  if (value == null || value.isEmpty) {
    return 'Harap masukkan $fieldName';
  }
  return null;
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
          backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Edit Info Profil',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF005466),
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Colors.white, size: 40,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OpenSansText.custom(
              text: "Nama",
              fontSize: 14,
              warna: MyColors.textBlack(),
              fontWeight: FontWeight.w600
            ),
            CostumeTextFormFieldWithoutBorderPrefix2(
              textformController: _nameController,
              hintText: 'Contoh: Michael',
              fillColors: Colors.white,
              iconSuffixColor: Colors.grey,
              validator: (value) => validateField(value, 'Nama'),
              focusNode: FocusNode(),
            ),
            SizedBox(height: 16.0),
            OpenSansText.custom(
              text: "User ID",
              fontSize: 14,
              warna: MyColors.textBlack(),
              fontWeight: FontWeight.w600
            ),
            CostumeTextFormFieldWithoutBorderPrefix2(
              textformController: _userIDController,
              hintText: 'Masukkan User ID',
              fillColors: Colors.white,
              iconSuffixColor: Colors.grey,
              validator: (value) => validateField(value, 'User ID'),
              focusNode: FocusNode(),
            ),
            SizedBox(height: 20),
              SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    onPressed: () async {
  if (_formKey.currentState!.validate()) {
    try {
      await context.read<ProfileProvider>().updateProfile({
        'nama': _nameController.text,
        'userId': _userIDController.text,
      });
      
      // Show success dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: MyColors.bluedark(),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Ubah Data Berhasil',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                                Padding(                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 16),
                      CircleAvatar(
                        backgroundColor: Colors.green,
                        radius: 30,
                        child: Icon(Icons.check, color: Colors.white, size: 30),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Data telah berhasil diperbarui',
                        style: TextStyle(fontSize: 14, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ).then((_) {
        Navigator.pop(context);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile')),
      );
    }
  }
},

    child: Text('Simpan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF005466),
      foregroundColor: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 17),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),
  ),)
            ],
          ),
        ),
      ),
    );
  }
}