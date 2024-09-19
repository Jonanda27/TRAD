import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

void main() async {
  runApp(GenerateQRApp());
}

class GenerateQRApp extends StatefulWidget {
  @override
  State<GenerateQRApp> createState() => _GenerateQRAppState();
}

class _GenerateQRAppState extends State<GenerateQRApp> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Generate QR Code'),
        ),
        body: Container(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'Enter text to generate QR code',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
              SizedBox(
                height: 20,
              ),
              controller.text != ''
                  ? PrettyQr(data: controller.text)
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}
