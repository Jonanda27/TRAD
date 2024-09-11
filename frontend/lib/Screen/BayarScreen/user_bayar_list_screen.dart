import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:trad/Screen/BayarScreen/berhasil_bayar.dart';
import '../../Model/RestAPI/service_bayar.dart';
import 'verifikasi_bayar.dart'; // Import your new verification page

class UserBayarScreen extends StatefulWidget {
  final String noNota;
  final int idPembeli;

  UserBayarScreen({required this.noNota, required this.idPembeli});

  @override
  _UserBayarScreenState createState() => _UserBayarScreenState();
}

class _UserBayarScreenState extends State<UserBayarScreen> {
  final ApiService apiService = ApiService();
  final NumberFormat currencyFormat = NumberFormat('#,##0', 'id');
  late Future<Map<String, dynamic>> _transactionDetails;

  @override
  void initState() {
    super.initState();
    _transactionDetails = apiService.transaksiBayar(
      widget.noNota,
      widget.idPembeli,
    );
  }

  String formatCurrency(dynamic amount) {
    if (amount is String) {
      amount = double.tryParse(amount) ?? 0;
    }
    return currencyFormat.format(amount);
  }

  String formatDate(String dateStr) {
    try {
      final dateTime = DateFormat('yyyy-MM-dd').parse(dateStr);
      return DateFormat('yyyy MMMM dd').format(dateTime);
    } catch (e) {
      return dateStr;
    }
  }

  String formatTime(String timeStr) {
    try {
      final time = DateFormat('HH:mm:ss').parse(timeStr);
      return DateFormat('HH:mm').format(time);
    } catch (e) {
      return timeStr;
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _navigateToVerification() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerifikasiPinPage(
          onPinVerified: (pin) async {
            final response = await _processPayment(pin);
            return response;
          },
        ),
      ),
    );
  }

  Future<void> _processPayment(String pin) async {
    bool useVoucher = true;

    try {
      final response = await apiService.transaksiBayarSelanjutnya(
        widget.noNota,
        widget.idPembeli,
        pin,
        useVoucher,
      );

      if (response != null && !response.containsKey('error')) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BerhasilBayarPage(
              jumlahTunai: response['totalBelanjaTunai'] ?? 0,
              userId: widget.idPembeli,
            ),
          ),
        );
      } else {
        _showMessage(response != null
            ? response['error']
            : 'PIN salah atau gagal verifikasi, silakan coba lagi.');
      }
    } catch (e) {
      _showMessage('Terjadi kesalahan: $e');
    }
  }

  Future<Map<String, dynamic>> onPinVerified(
      String pin, bool useVoucher) async {
    try {
      var response = await apiService.transaksiBayarSelanjutnya(
          widget.noNota, widget.idPembeli, pin, useVoucher);

      if (response != null && response.containsKey('message')) {
        return response;
      } else {
        return {'error': 'Terjadi kesalahan saat verifikasi PIN.'};
      }
    } catch (e) {
      return {'error': 'Terjadi kesalahan: $e'};
    }
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Color(0xFF005466),
      title: Text('Detail Pembayaran'),
    ),
    body: Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('/img/bekgron.png'), // Ensure this path is correct
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
            final totalBelanjaTunai = transactionData['totalBelanjaTunai'] ?? 0;
            final totalBelanjaVoucher =
                transactionData['totalBelanjaVoucher'] ?? 0;
            final tanggal = formatDate(transactionData['tanggal'] ?? '');
            final waktu = formatTime(transactionData['waktu'] ?? '');

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      Text(
                        transactionData['namaToko'],
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF005466),
                        ),
                      ),
                      Divider(
                        color: Colors.grey[300],
                        thickness: 1.0,
                      ),
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
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 55),
                      Text(
                        'List Produk',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromRGBO(36, 75, 89, 1),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Product item layout without card
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              child: Icon(Icons.image, size: 24),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    transactionData['detailProduk'][0]
                                            ['namaProduk'] ??
                                        'Unknown Product',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF005466),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/svg/icons/icons-money.svg',
                                        width: 16,
                                        height: 16,
                                        color: Color(0xFF005466),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Rp ${formatCurrency(transactionData['detailProduk'][0]['hargaProduk'] ?? 0)},-',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF005466),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/svg/icons/icons-voucher.svg',
                                        width: 16,
                                        height: 16,
                                        color: Color(0xFF005466),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${formatCurrency(transactionData['detailProduk'][0]['totalVoucherPerProduk'] ?? 0)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF005466),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'x ${transactionData['detailProduk'][0]['kuantitasProduk'] ?? 1}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF005466),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/svg/icons/icons-money.svg',
                                      width: 16,
                                      height: 16,
                                      color: Color(0xFF005466),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Rp ${formatCurrency(transactionData['detailProduk'][0]['hargaProduk'] ?? 0)},-',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF005466),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/svg/icons/icons-voucher.svg',
                                      width: 16,
                                      height: 16,
                                      color: Color(0xFF005466),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${formatCurrency(transactionData['detailProduk'][0]['totalVoucherPerProduk'] ?? 0)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF005466),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
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
                    onPressed: _navigateToVerification,
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
                    child:
                        Text('Bayar (${formatCurrency(totalBelanjaVoucher)})'),
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
