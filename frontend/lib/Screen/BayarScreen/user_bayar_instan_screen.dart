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
    _transactionDetails = apiService.transaksiBayar(widget.noNota, widget.idPembeli);
  }

  String formatCurrency(dynamic amount) {
    if (amount is String) {
      amount = double.tryParse(amount) ?? 0;
    }
    return currencyFormat.format(amount);
  }

  String formatDate(String dateStr) {
    try {
      final dateTime = DateFormat('yyyy-MM-dd').parse(dateStr); // Format sesuai dengan input tanggal
      return DateFormat('yyyy MMMM dd').format(dateTime); // Format hasil
    } catch (e) {
      return dateStr; // Jika terjadi kesalahan saat parsing, kembalikan string asli
    }
  }

  String formatTime(String timeStr) {
    try {
      final time = DateFormat('HH:mm:ss').parse(timeStr); // Format sesuai dengan input waktu
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            final totalBelanjaVoucher = transactionData['totalBelanjaVoucher'] ?? 0;
            final double bagiHasilPersenanDouble = double.tryParse(transactionData['bagiHasilPersenan'].toString()) ?? 0.0;
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
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Total Pembayaran',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
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
                                  style: TextStyle(fontWeight: FontWeight.bold)),
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
                    child: Text('Bayar (${formatCurrency(totalBelanjaVoucher)})'),
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
