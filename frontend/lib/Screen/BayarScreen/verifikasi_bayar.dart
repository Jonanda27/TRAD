import 'package:flutter/material.dart';

class VerifikasiPinPage extends StatefulWidget {
  final Function(String) onPinVerified;

  VerifikasiPinPage({required this.onPinVerified});

  @override
  _VerifikasiPinPageState createState() => _VerifikasiPinPageState();
}

class _VerifikasiPinPageState extends State<VerifikasiPinPage> {
  final int _pinLength = 6;
  late List<TextEditingController> _pinControllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _pinControllers = List.generate(_pinLength, (_) => TextEditingController());
    _focusNodes = List.generate(_pinLength, (_) => FocusNode());
  }

  @override
  void dispose() {
    _pinControllers.forEach((controller) => controller.dispose());
    _focusNodes.forEach((focusNode) => focusNode.dispose());
    super.dispose();
  }

  void _onPinEntered(int index, String value) {
    if (value.isNotEmpty) {
      if (index + 1 < _pinLength) {
        FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
      } else {
        FocusScope.of(context).unfocus(); // Hide keyboard when finished
      }
    } else if (index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }
  }

  void _onVerifyPin() {
    String pin = _pinControllers.map((controller) => controller.text).join();
    widget.onPinVerified(pin);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Verifikasi PIN',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF005466),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text(
              'Masukkan PIN Anda untuk melanjutkan pembayaran',
              style: TextStyle(fontSize: 16,),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_pinLength, (index) {
                return Container(
                  width: 40,
                  child: TextField(
                    controller: _pinControllers[index],
                    focusNode: _focusNodes[index],
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      counterText: '',
                      border: UnderlineInputBorder(),
                    ),
                    onChanged: (value) => _onPinEntered(index, value),
                  ),
                );
              }),
            ),
            SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: _onVerifyPin,
                child: Text('Lanjut'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(0, 84, 102, 1),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
