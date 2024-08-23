// Inside ubah_pin.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trad/Model/RestAPI/service_profile.dart';
import 'package:trad/Screen/HomeScreen/home_screen.dart';
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

  @override
  void dispose() {
    _oldPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _updatePin() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId'); // Retrieve the userId from SharedPreferences

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User ID not found!')),
      );
      return;
    }

    if (_newPinController.text != _confirmPinController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PIN baru dan konfirmasi PIN tidak cocok!')),
      );
      return;
    }

    try {
      final success = await ProfileService.updatePin(
        userId,
        _oldPinController.text,
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
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(0, 84, 102, 1),
        title: Text(
          'Ubah PIN',
          style: TextStyle(
            color: Colors.white, // White text color
          ),
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
                  labelText: 'PIN Lama',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isOldPinVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isOldPinVisible = !_isOldPinVisible;
                      });
                    },
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isOldPinSubmitted = true;
                  });
                },
                child: Text(
                  'Simpan',
                  style: TextStyle(color: Colors.white), // White text color
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
                'Masukkan PIN Baru',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _newPinController,
                obscureText: !_isNewPinVisible,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'PIN Baru',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isNewPinVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isNewPinVisible = !_isNewPinVisible;
                      });
                    },
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              TextField(
                controller: _confirmPinController,
                obscureText: !_isConfirmPinVisible,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Konfirmasi PIN Baru',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPinVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPinVisible = !_isConfirmPinVisible;
                      });
                    },
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updatePin,
                child: Text(
                  'Simpan',
                  style: TextStyle(color: Colors.white), // White text color
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
