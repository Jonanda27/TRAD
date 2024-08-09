import 'package:flutter/material.dart';

class VerifikasiPinPage extends StatefulWidget {
  final Function(String) onPinVerified;

  VerifikasiPinPage({required this.onPinVerified});

  @override
  _VerifikasiPinPageState createState() => _VerifikasiPinPageState();
}

class _VerifikasiPinPageState extends State<VerifikasiPinPage> {
  TextEditingController _pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ubah Rekening Bank',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Color.fromRGBO(0, 84, 102, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Masukkan PIN untuk melanjutkan proses ubah rekening bank'),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              decoration: InputDecoration(
                counterText: '',
                hintText: 'PIN',
              ),
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextButton(
                  child: Text('Batal'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                SizedBox(width: 20.0),
                ElevatedButton(
                  child: Text('Lanjut'),
                  onPressed: () {
                    // Lakukan verifikasi PIN di sini
                    if (_pinController.text == '123456') { // Contoh PIN yang valid
                      widget.onPinVerified(_pinController.text);
                      // Menampilkan dialog verifikasi berhasil
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 50.0,
                                ),
                                SizedBox(height: 10.0),
                                Text(
                                  'Rekening Bank telah berhasil diperbarui',
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: Text('OK'),
                                onPressed: () {
                                  Navigator.of(context).pop(); // Close the dialog
                                  Navigator.of(context).pop(); // Close the VerifikasiPinPage
                                },
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      // Menampilkan dialog kesalahan
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  Icons.error,
                                  color: Colors.red,
                                  size: 50.0,
                                ),
                                SizedBox(height: 10.0),
                                Text(
                                  'PIN salah, coba lagi.',
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: Text('OK'),
                                onPressed: () {
                                  Navigator.of(context).pop(); // Close the dialog
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }
}
