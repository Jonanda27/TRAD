import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:trad/Screen/BayarScreen/input_kode_bayar.dart';
import 'package:trad/Screen/BayarScreen/qr_screen.dart';
import '../../Model/RestAPI/service_bayar.dart';

class BayarScreen extends StatefulWidget {
  final int userId;

  BayarScreen({required this.userId});

  @override
  _BayarScreenState createState() => _BayarScreenState();
}

class _BayarScreenState extends State<BayarScreen> {
  final ApiService apiService = ApiService();
  late Future<Map<String, dynamic>> _pembeliTransaksi;
  final NumberFormat currencyFormat = NumberFormat('#,##0', 'id');

  @override
  void initState() {
    super.initState();
    _pembeliTransaksi = apiService.getPembeliTransaksi(widget.userId);
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

  Color _getStatusBackgroundColor(String status) {
    switch (status.toLowerCase()) {
      case 'dalam proses':
        return Color(0xFFFFF9DA);
      case 'belum dibayar':
        return Color(0xFFD9D9D9);
      default:
        return Colors.orange[100]!;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'dalam proses':
        return Color(0xFFFF9900);
      case 'belum dibayar':
        return Color(0xFF9CA3AF);
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bayar',
              style: TextStyle(
                color: Color(0xFF005466),
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'OpenSans',
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<Map<String, dynamic>>(
              future: _pembeliTransaksi,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Gagal memuat data');
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return Text('Data tidak ditemukan');
                } else {
                  final profileData = snapshot.data!;
                  final saldoVoucher = profileData['saldoVoucher'] ?? 0;

                  return Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/img/tradd.png'),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Voucher Saya',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formatCurrency(saldoVoucher),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Add functionality to top up balance
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Color(0xFF005466),
                            backgroundColor: Colors.white,
                          ),
                          child: const Text(
                            'Isi Saldo',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'OpenSans',
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 24),
            const Divider(color: Colors.grey, thickness: 1.0),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  'Cari Tagihan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF005466),
                    fontFamily: 'OpenSans',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Card(
                    elevation: 1,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: const BorderSide(
                        color: Color(0xFFD4D4D4),
                        width: 1.0,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                InputKodeBayarScreen(userId: widget.userId),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: const [
                            Icon(
                              Icons.format_list_bulleted,
                              color: Color(0xFF006064),
                              size: 32,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Input Kode Bayar',
                              style: TextStyle(
                                color: Color(0xFF006064),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                fontFamily: 'OpenSans',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    elevation: 1,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: const BorderSide(
                        color: Color(0xFFD4D4D4),
                        width: 1.0,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QRScanScreen(
                                idPembeli: widget
                                    .userId), // Pastikan userId di sini sesuai
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: const [
                            Icon(
                              Icons.qr_code_scanner,
                              color: Color(0xFF006064),
                              size: 32,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Scan QR',
                              style: TextStyle(
                                color: Color(0xFF006064),
                                fontWeight: FontWeight.bold,
                                fontFamily: 'OpenSans',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(color: Colors.grey, thickness: 1.0),
            const SizedBox(height: 24),
            const Text(
              'Transaksi Berjalan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF005466),
                fontFamily: 'OpenSans',
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: _pembeliTransaksi,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Gagal memuat transaksi'));
                  } else if (!snapshot.hasData ||
                      snapshot.data == null ||
                      snapshot.data!['transaksiBerjalan'] == null) {
                    return Center(child: Text('Belum ada transaksi'));
                  } else {
                    final transaksiList =
                        snapshot.data!['transaksiBerjalan'] as List<dynamic>;
                    return ListView.builder(
                      itemCount: transaksiList.length,
                      itemBuilder: (context, index) {
                        final transaksi = transaksiList[index];
                        final status = transaksi['status'];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            side: BorderSide(
                              color: Color(0xFFD4D4D4),
                              width: 1.0,
                            ),
                          ),
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  // Handle navigation to detail pages if needed
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            transaksi['noNota'],
                                            style: const TextStyle(
                                              color: Color(0xFF005466),
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: _getStatusBackgroundColor(
                                                  status),
                                              borderRadius:
                                                  BorderRadius.circular(4.0),
                                            ),
                                            child: Text(
                                              status,
                                              style: TextStyle(
                                                color:
                                                    _getStatusTextColor(status),
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${transaksi['tanggalPembayaran']} - ${transaksi['jamPembayaran']}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const Divider(color: Colors.grey),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Total Biaya',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SvgPicture.asset(
                                            'assets/svg/icons/icons-money.svg',
                                            height: 16,
                                            width: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Rp. ${formatCurrency(transaksi['totalBelanjaTunai'])},-',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF244B59),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              SvgPicture.asset(
                                                'assets/svg/icons/icons-voucher2.svg',
                                                height: 16,
                                                width: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Rp. ${formatCurrency(transaksi['totalBelanjaVoucher'])},-',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF244B59),
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
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
