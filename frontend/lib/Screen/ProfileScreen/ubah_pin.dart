// Inside ubah_pin.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trad/Model/RestAPI/service_profile.dart';
import 'package:trad/Screen/ProfileScreen/edit_profile.dart';
// Import the ProfileService

class UbahPinPage extends StatefulWidget {
  @override
  _UbahPinPageState createState() => _UbahPinPageState();
}

class _UbahPinPageState extends State<UbahPinPage> {
  bool _isOldPinVisible = false;
  bool _isNewPinVisible = false;
  bool _isConfirmPinVisible = false;
  bool _isOldPinSubmitted = false;
  final _oldPinController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  String? _oldPinError;
  String? _newPinError;
  String? _confirmPinError;

  @override
  void dispose() {
    _oldPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

// Add these methods to your _UbahPinPageState class
  bool _validateOldPin() {
    String oldPin = _oldPinController.text;
    if (oldPin.length != 6 || !RegExp(r'^[0-9]+$').hasMatch(oldPin)) {
      setState(() {
        _oldPinError = "PIN lama harus terdiri dari 6 digit angka";
      });
      return false;
    }
    setState(() {
      _oldPinError = null;
    });
    return true;
  }

  bool _validateNewPin() {
    String newPin = _newPinController.text;
    if (newPin.length != 6 || !RegExp(r'^[0-9]+$').hasMatch(newPin)) {
      setState(() {
        _newPinError = "PIN baru harus terdiri dari 6 digit angka";
      });
      return false;
    }
    setState(() {
      _newPinError = null;
    });
    return true;
  }

  bool _validateConfirmPin() {
    String newPin = _newPinController.text;
    String confirmPin = _confirmPinController.text;
    if (confirmPin != newPin) {
      setState(() {
        _confirmPinError = "PIN konfirmasi tidak cocok dengan PIN baru";
      });
      return false;
    }
    setState(() {
      _confirmPinError = null;
    });
    return true;
  }

  Future<void> _checkOldPin() async {
    if (!_validateOldPin()) {
      return;
    }

    try {
      final success = await ProfileService.checkOldPin(_oldPinController.text);

      if (success) {
        setState(() {
          _isOldPinSubmitted = true;
          _oldPinError = null;
        });
      } else {
        setState(() {
          _oldPinError = 'PIN lama salah';
        });
      }
    } catch (e) {
      setState(() {
        _oldPinError = 'Error: ${e.toString()}';
      });
    }
  }

  Future<void> _updatePin() async {
    if (_newPinController.text.isEmpty || _confirmPinController.text.isEmpty) {
      setState(() {
        _newPinError = _newPinController.text.isEmpty
            ? 'PIN baru tidak boleh kosong'
            : null;
        _confirmPinError = _confirmPinController.text.isEmpty
            ? 'Konfirmasi PIN tidak boleh kosong'
            : null;
      });
      return;
    }

    if (_newPinController.text != _confirmPinController.text) {
      setState(() {
        _confirmPinError = 'PIN baru dan konfirmasi PIN tidak cocok!';
      });
      return;
    }

    // if (_newPinController.text != _confirmPinController.text) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('PIN baru dan konfirmasi PIN tidak cocok!')),
    //   );
    //   return;
    // }
    // Proceed with PIN update if all validations pass
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User ID not found!')),
      );
      return;
    }

    try {
      final success = await ProfileService.updatePin(
        userId,
        _newPinController.text,
      );

      if (success) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6), // Radius 6 for dialog
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppBar(
                    backgroundColor: const Color.fromRGBO(0, 84, 102, 1),
                    title: Text(
                      'Ubah PIN Berhasil',
                      style: TextStyle(
                        color: Colors.white, // White text color
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
                    'PIN telah berhasil diperbaharui',
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
                          builder: (context) => EditProfilePage(),
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
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(0, 84, 102, 1),
        title: Text(
          'Ubah PIN',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            color: Colors.white,
            size: 40,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_isOldPinSubmitted) ...[
              Text(
                'Masukkan PIN Lama',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _oldPinController,
                obscureText: !_isOldPinVisible,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'PIN Lama',
                  errorText: _oldPinError,
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_oldPinError != null)
                        Icon(Icons.error, color: Colors.red),
                      IconButton(
                        icon: Icon(
                          _isOldPinVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isOldPinVisible = !_isOldPinVisible;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                keyboardType: TextInputType.number,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _checkOldPin,
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
            ] else ...[
              Text(
                'Masukkan PIN Baru',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _newPinController,
                obscureText: !_isNewPinVisible,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'PIN Baru',
                  errorText: _newPinError,
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_newPinError != null)
                        Icon(Icons.error, color: Colors.red),
                      IconButton(
                        icon: Icon(
                          _isNewPinVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isNewPinVisible = !_isNewPinVisible;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                keyboardType: TextInputType.number,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              SizedBox(height: 20),
              TextField(
                controller: _confirmPinController,
                obscureText: !_isConfirmPinVisible,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Konfirmasi PIN Baru',
                  errorText: _confirmPinError,
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_confirmPinError != null)
                        Icon(Icons.error, color: Colors.red),
                      IconButton(
                        icon: Icon(
                          _isConfirmPinVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPinVisible = !_isConfirmPinVisible;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                keyboardType: TextInputType.number,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updatePin,
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
