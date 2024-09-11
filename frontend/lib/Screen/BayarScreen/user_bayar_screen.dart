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

  Future<Map<String, dynamic>> onPinVerified(
      String pin, bool useVoucher) async {
    try {
      print('Verifying PIN: $pin'); // Debug: Print PIN being verified
      // Call the API service to verify the PIN
      var response = await apiService.transaksiBayarSelanjutnya(
          widget.noNota, widget.idPembeli, pin, useVoucher);

      print('API Response: $response'); // Debug: Print API response

      // Check the API response
      if (response != null && response.containsKey('message')) {
        return response; // Return the response containing the message
      } else {
        return {
          'error': 'Terjadi kesalahan saat verifikasi PIN.'
        }; // Return an error message if response does not contain a message
      }
    } catch (e) {
      print('Error verifying pin: $e'); // Debug: Print error if any
      return {'error': 'Terjadi kesalahan: $e'};
    }
  }

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
            // Process the payment and navigate to the success page
            final response = await _processPayment(pin);
            return response; // Pass the response back to VerifikasiPinPage
          },
        ),
      ),
    );
  }

  Future<void> _processPayment(String pin) async {
    // Assuming useVoucher is always true, or you can add a parameter to control this
    bool useVoucher = true;

    try {
      final response = await apiService.transaksiBayarSelanjutnya(
        widget.noNota,
        widget.idPembeli,
        pin,
        useVoucher,
      );

      // Check for success and navigate to the success page
      if (response != null && !response.containsKey('error')) {
        // Navigate to the BerhasilBayarPage on successful API hit
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BerhasilBayarPage(
              jumlahTunai: response['totalBelanjaTunai'] ??
                  0, // Default to 0 if not provided
              userId: widget.idPembeli, // Pass the userId here
            ),
          ),
        );
      } else {
        // Show an error message if the response contains an error
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
      appBar: AppBar(
        backgroundColor: Color(0xFF005466),
        title: Text('Detail Pembayaran'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
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
            final productName = transactionData['detailProduk'][0]
                    ['namaProduk'] ??
                'Unknown Product';
            final productPrice =
                transactionData['detailProduk'][0]['hargaProduk'] ?? 0;
            final productQuantity =
                transactionData['detailProduk'][0]['kuantitasProduk'] ?? 1;
            final totalHargaPerProduk =
                transactionData['detailProduk'][0]['totalHargaPerProduk'] ?? 0;
            final totalVoucherPerProduk = transactionData['detailProduk'][0]
                    ['totalVoucherPerProduk'] ??
                0;

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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.noNota,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        transactionData['tanggal'], // Dynamic date
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const Divider(height: 24, color: Colors.grey),
                      Text(
                        'List Produk',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Product item card with updated layout
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey[300],
                                child: Icon(Icons.image, size: 24),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      productName,
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
                                          'Rp ${formatCurrency(productPrice)},-',
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
                                          '${formatCurrency(totalVoucherPerProduk)}',
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
                                'x $productQuantity',
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
                                        'Rp ${formatCurrency(productPrice)},-',
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
                                        '${formatCurrency(totalVoucherPerProduk)}',
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
                    onPressed:
                        _navigateToVerification, // Navigate to verification page
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
    );
  }
}
