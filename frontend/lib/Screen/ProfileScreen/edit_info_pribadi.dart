import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:trad/Provider/profile_provider.dart';
import 'package:trad/utility/text_opensans.dart';
import 'package:trad/utility/warna.dart';
import 'package:trad/widget/component/costume_teksfield3.dart';

class EditInfoPribadiPage extends StatefulWidget {
  @override
  _EditInfoPribadiPageState createState() => _EditInfoPribadiPageState();
}

class _EditInfoPribadiPageState extends State<EditInfoPribadiPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  DateTime _birthDate = DateTime.now();
  String? _gender; // Changed to nullable

  @override
  void initState() {
    super.initState();
    final profileData = context.read<ProfileProvider>().profileData;
    _emailController.text = profileData['email'] ?? '';
    _phoneController.text = profileData['noHp'] ?? '';
    _birthDate = profileData['tanggalLahir'] != null
        ? DateTime.parse(profileData['tanggalLahir'])
        : DateTime.now();
    _gender = profileData['jenisKelamin'];
    _dateController.text = DateFormat('dd MMMM yyyy').format(_birthDate);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
        _dateController.text = DateFormat('dd MMMM yyyy').format(_birthDate);
      });
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
          backgroundColor: Colors.white,
    appBar: AppBar(
      title: Text('Edit Info Pribadi', style: TextStyle(color: Colors.white)),
      backgroundColor: Color(0xFF005466),
      leading: IconButton(
        icon: Icon(Icons.chevron_left, color: Colors.white, size: 40,),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    ),
    body: SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OpenSansText.custom(
              text: "Email",
              fontSize: 14,
              warna: MyColors.textBlack(),
              fontWeight: FontWeight.w600
            ),
            CostumeTextFormFieldWithoutBorderPrefix2(
              textformController: _emailController,
              hintText: 'Masukkan email',
              fillColors: Colors.white,
              iconSuffixColor: Colors.grey,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}');
                if (!emailRegex.hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
              focusNode: FocusNode(),
            ),
            SizedBox(height: 16),
            OpenSansText.custom(
              text: "Nomor Telepon",
              fontSize: 14,
              warna: MyColors.textBlack(),
              fontWeight: FontWeight.w600
            ),
            CostumeTextFormFieldWithoutBorderPrefix2(
              textformController: _phoneController,
              hintText: 'Masukkan nomor telepon',
              fillColors: Colors.white,
              iconSuffixColor: Colors.grey,
              validator: (value) {
                // Use the same validation logic as before
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
    if (value.startsWith('08')) {
      if (value.length < 10 || value.length > 15) {
        return 'Phone number should be between 10-15 digits';
      }
      if (!RegExp(r'^\d+$').hasMatch(value.substring(2))) {
        return 'Phone number should only contain digits after 08';
      }
    } else if (value.startsWith('+62')) {
      if (value.length < 11 || value.length > 16) {
        return 'Phone number should be between 11-16 digits including +62';
      }
      if (!RegExp(r'^\d+$').hasMatch(value.substring(3))) {
        return 'Phone number should only contain digits after +62';
      }
    } else {
      return 'Phone number must start with 08 or +62';
    }
    return null;  // This line ensures the error is cleared when all conditions are met
  },
  // autovalidateMode: AutovalidateMode.onUserInteraction,
),

              SizedBox(height: 16),
            OpenSansText.custom(
              text: "Tanggal Lahir",
              fontSize: 14,
              warna: MyColors.textBlack(),
              fontWeight: FontWeight.w600
            ),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: CostumeTextFormFieldWithoutBorderPrefix2(
                  textformController: _dateController,
                  hintText: 'Pilih tanggal lahir',
                  fillColors: Colors.white,
                  iconSuffixColor: Colors.grey,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harap masukkan tanggal lahir';
                    }
                    return null;
                  },
                  focusNode: FocusNode(),
                ),
              ),
            ),
            SizedBox(height: 16),
            OpenSansText.custom(
              text: "Jenis Kelamin",
              fontSize: 14,
              warna: MyColors.textBlack(),
              fontWeight: FontWeight.w600
            ),
            DropdownButtonFormField<String>(
  value: _gender,
  decoration: InputDecoration(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: Colors.black, // Warna border hitam
        width: 2.0, // Lebar border, bisa disesuaikan
      ),
    ),
  ),
  items: [
    DropdownMenuItem(child: Text('Laki-laki'), value: 'L'),
    DropdownMenuItem(child: Text('Perempuan'), value: 'P'),
  ],
  onChanged: (value) {
    setState(() {
      _gender = value;
    });
  },
),

            SizedBox(height: 24),
            // Keep the existing ElevatedButton code
          
              SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    onPressed: () async {
  if (_formKey.currentState!.validate()) {
    try {
      await context.read<ProfileProvider>().updatePersonalInfo({
        'email': _emailController.text,
        'noHp': _phoneController.text,
        'tanggalLahir': DateFormat('yyyy-MM-dd').format(_birthDate),
        'jenisKelamin': _gender ?? '',
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
                Padding(
                  padding: const EdgeInsets.all(16.0),
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
        SnackBar(content: Text('Failed to update personal info')),
      );
    }
  }
},

    child: Text('Simpan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF005466),
      foregroundColor: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 17),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),
  ),
)

            ],
          ),
        ),
      ),
    );
  }
}
