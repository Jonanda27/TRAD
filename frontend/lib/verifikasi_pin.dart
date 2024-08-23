import 'package:flutter/material.dart';

class VerifikasiPinPage extends StatefulWidget {
  final Function(String) onPinVerified;

  VerifikasiPinPage({required this.onPinVerified});

  @override
  _VerifikasiPinPageState createState() => _VerifikasiPinPageState();
}

class _VerifikasiPinPageState extends State<VerifikasiPinPage> {
  List<TextEditingController> _pinControllers =
      List.generate(6, (_) => TextEditingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Layanan Poin dan lainnya',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF005466),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text(
              'Verifikasi Pergantian Akun Bank',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Masukan PIN Anda untuk melanjutkan pergantian akun bank',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return Container(
                  width: 40,
                  child: TextField(
                    controller: _pinControllers[index],
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      counterText: '',
                      border: UnderlineInputBorder(),
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                  onPressed: () {
                    String pin = _pinControllers
                        .map((controller) => controller.text)
                        .join();
                    widget.onPinVerified(pin);
                  },
                  child: Text('Lanjut'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(0, 84, 102, 1),
                    foregroundColor: Colors.white,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}