import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:trad/Screen/BayarScreen/user_bayar_instan_screen.dart';
import 'package:trad/Screen/BayarScreen/user_bayar_list_screen.dart';
import '../../Model/RestAPI/service_bayar.dart'; // Pastikan import sesuai dengan path service_kasir Anda

class QRScanScreen extends StatefulWidget {
  final int idPembeli; // Tambahkan parameter untuk menerima idPembeli

  QRScanScreen({required this.idPembeli});

  @override
  _QRScanScreenState createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  final GlobalKey qrkey = GlobalKey(debugLabel: "QR");
  Barcode? result;
  QRViewController? controller;
  final ApiService serviceKasir = ApiService(); // Instance dari service

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: QRView(
              key: qrkey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (result != null)
                  ? Text("Barcode Data: ${result!.code}")
                  : const Text("Scan a Code"),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      setState(() {
        result = scanData;
      });

      if (result != null) {
        // Panggil fungsi untuk transaksi bayar dengan noNota yang diperoleh dari QR dan idPembeli
        await _transaksiBayar(result!.code!, widget.idPembeli);
      }
    });
  }

Future<void> _transaksiBayar(String noNota, int idPembeli) async {
  // Tampilkan loading indicator selama proses transaksi
  _showLoadingDialog();

  final response = await serviceKasir.transaksiBayar(noNota, idPembeli);
  Navigator.of(context).pop(); // Tutup loading indicator setelah respon diterima

  if (response.containsKey('error')) {
    // Jika ada error, tampilkan pesan error
    _showErrorDialog(response['error']);
  } else {
    // Jika berhasil, cek jenis transaksi
    String jenisTransaksi = response['jenisTransaksi'] ?? '';

    if (jenisTransaksi == 'list_produk_toko') {
      // Navigasi ke UserBayarScreen untuk 'list_produk_toko'
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserBayarScreen(
            noNota: noNota,
            idPembeli: idPembeli,
          ),
        ),
      );
    } else if (jenisTransaksi == 'bayar_instan') {
      // Navigasi ke UserBayarInstanScreen untuk 'bayar_instan'
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserBayarInstanScreen(
            noNota: noNota,
            idPembeli: idPembeli,
          ),
        ),
      );
    } else {
      // Jika jenis transaksi tidak dikenali
      _showErrorDialog('Jenis transaksi tidak dikenali');
    }
  }
}


  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text("Memproses transaksi...")
            ],
          ),
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Tutup"),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Sukses"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Tutup"),
            ),
          ],
        );
      },
    );
  }
}
