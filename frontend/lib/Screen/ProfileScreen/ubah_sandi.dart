import 'package:flutter/material.dart';
import 'package:trad/Model/RestAPI/service_profile.dart';
import 'package:trad/Screen/ProfileScreen/edit_profile.dart';

class UbahSandiPage extends StatefulWidget {
  @override
  _UbahSandiPageState createState() => _UbahSandiPageState();
}

class _UbahSandiPageState extends State<UbahSandiPage> {
  // bool _isNewPasswordVisible = false;
  // bool _isConfirmPasswordVisible = false;
  // final _newPasswordController = TextEditingController();
  // final _confirmPasswordController = TextEditingController();
  
  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isOldPasswordSubmitted = false;
  bool _allRequirementsMet = false;
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasNumber = false;

  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_hasMinLength || !_hasUppercase || !_hasNumber) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sandi baru tidak memenuhi persyaratan!')),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sandi baru dan konfirmasi sandi tidak cocok!')),
      );
      return;
    }

    try {
      final success = await ProfileService.changePassword(
        _newPasswordController.text,
      );

      if (success) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppBar(
                    backgroundColor: const Color.fromRGBO(0, 84, 102, 1),
                    title: Text(
                      'Ubah Sandi Berhasil',
                      style: TextStyle(color: Colors.white),
                    ),
                    automaticallyImplyLeading: false,
                    centerTitle: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Icon(Icons.check_circle, color: Colors.green, size: 100),
                  SizedBox(height: 20),
                  Text(
                    'Sandi telah berhasil diperbaharui',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => EditProfilePage()),
                      );
                    },
                  ),
                  SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _checkOldPassword() async {
  if (_oldPasswordController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Harap masukkan sandi lama')),
    );
    return;
  }

//   void _checkPassword(String value) {
//   setState(() {
//     _hasMinLength = value.length >= 8;
//     _hasUppercase = value.contains(RegExp(r'[A-Z]'));
//     _hasNumber = value.contains(RegExp(r'[0-9]'));
//     _allRequirementsMet = _hasMinLength && _hasUppercase && _hasNumber;
//   });
// }

  try { // Assuming you have this method
    final success = await ProfileService.checkOldPassword( _oldPasswordController.text);

    if (success) {
      setState(() {
        _isOldPasswordSubmitted = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sandi lama salah')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}')),
    );
  }
}

void _checkPassword(String value) {
  setState(() {
    _hasMinLength = value.length >= 8;
    _hasUppercase = value.contains(RegExp(r'[A-Z]'));
    _hasNumber = value.contains(RegExp(r'[0-9]'));
    _allRequirementsMet = _hasMinLength && _hasUppercase && _hasNumber;
  });
}


  Widget _buildPasswordRequirement(String text, bool isMet) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.cancel,
          color: isMet ? Colors.green : Colors.red,
          size: 16,
        ),
        SizedBox(width: 8),
        Text(text, style: TextStyle(fontSize: 14)),
      ],
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
          backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(0, 84, 102, 1),
        title: Text(
          'Ubah Sandi',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_isOldPasswordSubmitted) ...[
              Text(
                'Masukkan Sandi Lama',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _oldPasswordController,
                obscureText: !_isOldPasswordVisible,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  // labelText: 'Sandi Lama',
                  hintText: 'Sandi Lama',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isOldPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isOldPasswordVisible = !_isOldPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
  width: double.infinity,
  child: ElevatedButton(
                onPressed:  _checkOldPassword,
                child: Text(
      'Simpan',
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF005466),
      foregroundColor: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 17),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),
              ),)
            ] else ...[
            Text(
              'Masukkan Sandi Baru',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
  controller: _newPasswordController,
  obscureText: !_isNewPasswordVisible,
  onChanged: _checkPassword,
  decoration: InputDecoration(
    border: OutlineInputBorder(),
    hintText: 'Sandi Baru',
    suffixIcon: IconButton(
      icon: Icon(
        _isNewPasswordVisible ? Icons.visibility : Icons.visibility_off,
      ),
      onPressed: () {
        setState(() {
          _isNewPasswordVisible = !_isNewPasswordVisible;
        });
      },
    ),
  ),
),
SizedBox(height: 10),
Visibility(
  visible: !_allRequirementsMet,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildPasswordRequirement('Butuh minimal 8 Karakter', _hasMinLength),
      _buildPasswordRequirement('Memiliki 1 Huruf Kapital', _hasUppercase),
      _buildPasswordRequirement('Mengandung minimal 1 angka', _hasNumber),
    ],
  ),
),
SizedBox(height: 20),
        
              TextField(
              controller: _confirmPasswordController,
              obscureText: !_isConfirmPasswordVisible,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                // labelText: 'Konfirmasi Sandi Baru',
                hintText: 'Konfirmasi Sandi Baru',
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isConfirmPasswordVisible =
                          !_isConfirmPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    onPressed: _changePassword,
    child: Text(
      'Simpan',
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    ),
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
            ]
          ],
        ),
      ),
    );
  }
}