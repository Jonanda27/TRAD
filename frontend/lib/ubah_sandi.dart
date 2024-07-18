import 'package:flutter/material.dart';
import 'package:trad/Screen/HomeScreen/home_screen.dart';
import 'package:trad/main.dart';

class UbahSandiPage extends StatefulWidget {
  @override
  _UbahSandiPageState createState() => _UbahSandiPageState();
}

class _UbahSandiPageState extends State<UbahSandiPage> {
  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isOldPasswordSubmitted = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(0, 84, 102, 1),
        title: Text(
          'Ubah Sandi',
          style: TextStyle(
            color: Colors.white, // Warna teks putih
          ),
        ),
        centerTitle: false, // Atur menjadi false agar teks berada di sebelah kiri
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
                  labelText: 'Sandi Lama',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isOldPasswordVisible ? Icons.visibility : Icons.visibility_off,
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
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isOldPasswordSubmitted = true;
                  });
                },
                child: Text(
                  'Simpan',
                  style: TextStyle(color: Colors.white), // Warna teks putih
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(0, 84, 102, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6), // Radius 6
                  ),
                ),
              ),
            ] else ...[
              Text(
                'Masukkan Sandi Baru',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _newPasswordController,
                obscureText: !_isNewPasswordVisible,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Sandi Baru',
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
              SizedBox(height: 20),
              TextField(
                controller: _confirmPasswordController,
                obscureText: !_isConfirmPasswordVisible,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Konfirmasi Sandi Baru',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_newPasswordController.text == _confirmPasswordController.text) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6), // Radius 6 untuk dialog
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AppBar(
                               backgroundColor:
                                    const Color.fromRGBO(0, 84, 102, 1),
                                title: Text(
                                  'Ubah Sandi Berhasil',
                                  style: TextStyle(
                                    color: Colors.white, // Warna teks putih
                                  ),
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
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 100,
                              ),
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
                                    MaterialPageRoute(
                                      builder: (context) => HomeScreen(),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
                        );
                      },
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Sandi baru dan konfirmasi sandi tidak cocok!'),
                      ),
                    );
                  }
                },
                child: Text(
                  'Simpan',
                  style: TextStyle(color: Colors.white), // Warna teks putih
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(0, 84, 102, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6), // Radius 6
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}