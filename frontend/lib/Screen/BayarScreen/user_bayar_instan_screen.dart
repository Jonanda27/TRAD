import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:trad/Screen/BayarScreen/berhasil_bayar.dart';
import '../../Model/RestAPI/service_bayar.dart';
import 'verifikasi_bayar.dart'; // Import your new verification page

class UserBayarInstanScreen extends StatefulWidget {
  final String noNota;
  final int idPembeli;

  UserBayarInstanScreen({required this.noNota, required this.idPembeli});

  @override
  _UserBayarInstanScreenState createState() => _UserBayarInstanScreenState();
}

class _UserBayarInstanScreenState extends State<UserBayarInstanScreen> {
  final ApiService apiService = ApiService();
  final NumberFormat currencyFormat = NumberFormat('#,##0', 'id');
  late Future<Map<String, dynamic>> _transactionDetails;

  @override
  void initState() {
    super.initState();
    _transactionDetails =
        apiService.transaksiBayar(widget.noNota, widget.idPembeli);
  }

  String formatCurrency(dynamic amount) {
    if (amount is String) {
      amount = double.tryParse(amount) ?? 0;
    }
    return currencyFormat.format(amount);
  }

  String formatDate(String dateStr) {
    try {
      final dateTime = DateFormat('yyyy-MM-dd')
          .parse(dateStr); // Format sesuai dengan input tanggal
      return DateFormat('yyyy MMMM dd').format(dateTime); // Format hasil
    } catch (e) {
      return dateStr; // Jika terjadi kesalahan saat parsing, kembalikan string asli
    }
  }

  String formatTime(String timeStr) {
    try {
      final time = DateFormat('HH:mm:ss')
          .parse(timeStr); // Format sesuai dengan input waktu
      return DateFormat('HH:mm').format(time); // Format hasil tanpa detik
    } catch (e) {
      return timeStr; // Jika terjadi kesalahan saat parsing, kembalikan string asli
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showVerificationFailedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF337F8F),
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(8.0)),
                ),
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Verifikasi Gagal',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.close,
                      color: Colors.red,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Kode PIN salah',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showInsufficientVoucherDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFF337F8F),
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.close, color: const Color.fromARGB(0, 255, 255, 255)),
                    
                  Text(
                    'Voucher Tidak Mencukupi',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Pembayaran tidak dilakukan.\nMohon isi voucher terlebih dahulu',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                  SizedBox(height: 20),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Add logic to navigate to voucher top-up page
                      // For example:
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => VoucherTopUpPage()));
                    },
                    child: Text(
                      'Isi voucher',
                      style: TextStyle(
                        color: Color(0xFF337F8F),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Color(0xFF337F8F), width: 2),
                      minimumSize: Size(double.infinity, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

  void _showNoVoucherDialog(double totalBelanjaVoucher) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Penggunaan Voucher tidak ditemukan, Anda harus membayar Rp. ${formatCurrency(totalBelanjaVoucher)} secara tunai.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Isi Voucher?', // Display "Isi Voucher" as plain text
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                            _navigateToVerification(); // Proceed to verification
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF337F8F),
                            foregroundColor: Colors.white,
                          ),
                          child: Text('Ya'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
                          ),
                          child: Text('Tidak'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handlePayment(Map<String, dynamic> transactionData) {
    double totalBelanjaVoucher =
        double.tryParse(transactionData['totalBelanjaVoucher'].toString()) ??
            0.0;
    double saldoVoucherPembeli =
        double.tryParse(transactionData['saldoVoucherPembeli'].toString()) ??
            0.0;

    if (totalBelanjaVoucher > saldoVoucherPembeli) {
      _showInsufficientVoucherDialog(); // Show dialog when voucher is insufficient
    } else {
      _navigateToVerification(); // Proceed to verification when voucher is sufficient
    }
  }

  void _navigateToVerification({bool isVoucherUsed = true}) {
    num saldoVoucher = isVoucherUsed
        ? widget.idPembeli
        : 0; // Set saldo voucher to 0 if not used

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerifikasiPinPage(
          onPinVerified: (pin) async {
            final response =
                await _processPayment(pin, isVoucherUsed: isVoucherUsed);
            return response;
          },
        ),
      ),
    );
  }

 Future<void> _processPayment(String pin, {bool isVoucherUsed = true}) async {
  bool useVoucher = isVoucherUsed; // Menentukan apakah voucher digunakan berdasarkan parameter

  try {
    final response = await apiService.transaksiBayarSelanjutnya(
      widget.noNota,
      widget.idPembeli,
      pin,
      useVoucher,
    );

    if (response != null && !response.containsKey('error')) {
      double jumlahTunai = double.tryParse(response['totalBelanjaTunai']) ?? 0.0;
      double totalBelanjaVoucher = double.tryParse(response['totalBelanjaVoucher']) ?? 0.0;
      double jumlahTunaiAkhir = jumlahTunai - totalBelanjaVoucher;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BerhasilBayarPage(
            jumlahTunai: jumlahTunaiAkhir, // Menggunakan jumlahTunaiAkhir
            userId: widget.idPembeli,
          ),
        ),
      );
    } else {
      _showVerificationFailedDialog(); // Menampilkan dialog jika gagal
    }
  } catch (e) {
    _showMessage('Terjadi kesalahan: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image:
                AssetImage('assets/img/bekgron.png'), // Ensure this path is correct
            fit: BoxFit.cover,
          ),
        ),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _transactionDetails,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Gagal memuat data transaksi'));
            } else if (!snapshot.hasData || snapshot.data == null) {
              return Center(child: Text('Data transaksi tidak ditemukan'));
            } else {
              final transactionData = snapshot.data!;
              double totalBelanjaVoucher = double.tryParse(
                      transactionData['totalBelanjaVoucher'].toString()) ??
                  0.0;
              double saldoVoucherPembeli = double.tryParse(
                      transactionData['saldoVoucherPembeli'].toString()) ??
                  0.0;
              double totalBelanjaTunai = double.tryParse(
                      transactionData['totalBelanjaTunai'].toString()) ??
                  0.0;

              final double bagiHasilPersenanDouble = double.tryParse(
                      transactionData['bagiHasilPersenan'].toString()) ??
                  0.0;
              final tanggal = formatDate(transactionData['tanggal'] ?? '');
              final waktu = formatTime(transactionData['waktu'] ?? '');

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transactionData['namaToko'],
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF005466),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Divider(
                            color: Colors.grey[300],
                            thickness: 1.0,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.noNota,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                '$tanggal - $waktu',
                                style: TextStyle(
                                  fontSize: 10, // Perkecil font size
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 85),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Belanja',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF005466),
                                ),
                              ),
                              Text(
                                'Rp ${formatCurrency(totalBelanjaTunai)},-',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF002D3A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Voucher (${bagiHasilPersenanDouble.toInt()}%)',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF005466),
                                ),
                              ),
                              Text(
                                '${formatCurrency(totalBelanjaVoucher)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF002D3A),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Divider(
                    color: Colors.grey[300],
                    thickness: 1.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Total Pembayaran',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/svg/icons/icons-money.svg',
                                      width: 18,
                                      height: 18,
                                      color: Color(0xFF005466),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Rp. ${formatCurrency(totalBelanjaTunai)},-',
                                      style: const TextStyle(
                                        color: Color(0xFF005466),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(width: 65),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/svg/icons/icons-voucher.svg',
                                      width: 18,
                                      height: 18,
                                      color: Color(0xFF005466),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${formatCurrency(totalBelanjaVoucher)}',
                                      style: const TextStyle(
                                        color: Color(0xFF005466),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        _handlePayment(transactionData); // Correct usage
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: Color(0xFF005466),
                        foregroundColor: Color(0xFFF8F8F8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: Text(
                          'Bayar (${formatCurrency(saldoVoucherPembeli)})'),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
