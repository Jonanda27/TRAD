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
  bool isProcessing = false; // Flag untuk mendeteksi apakah transaksi sedang diproses

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
      if (!isProcessing) { // Cek apakah transaksi sedang diproses
        setState(() {
          result = scanData;
          isProcessing = true; // Set flag menjadi true saat transaksi mulai diproses
        });

        if (result != null) {
          // Panggil fungsi untuk transaksi bayar dengan noNota yang diperoleh dari QR dan idPembeli
          await _transaksiBayar(result!.code!, widget.idPembeli);
        }
      }
    });
  }

  Future<void> _transaksiBayar(String noNota, int idPembeli) async {
    // Tampilkan loading indicator selama proses transaksi
    _showLoadingDialog();

    final response = await serviceKasir.transaksiBayar(noNota, idPembeli);
    Navigator.of(context).pop(); // Tutup loading indicator setelah respon diterima

    if (response.containsKey('error')) {
      // Jika ada error, tampilkan pesan "Transaksi tidak ada"
      _showErrorDialog("Transaksi tidak ada");
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
        controller?.pauseCamera(); // Hentikan scan jika berhasil
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
        controller?.pauseCamera(); // Hentikan scan jika berhasil
      } else {
        // Jika jenis transaksi tidak dikenali
        _showErrorDialog('Transaksi tidak ada');
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

  void _showErrorDialog(String message) async {
    await controller?.pauseCamera(); // Hentikan kamera saat dialog muncul
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Gagal"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resumeCamera(); // Aktifkan kembali kamera saat pengguna menekan "Lanjut"
              },
              child: Text("Lanjut"),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk melanjutkan kembali kamera
  void _resumeCamera() {
    controller?.resumeCamera();
    setState(() {
      isProcessing = false; // Izinkan scan ulang setelah dialog ditutup
    });
  }

  @override
  void dispose() {
    controller?.dispose(); // Membersihkan controller setelah selesai
    super.dispose();
  }
}
