import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trad/Model/RestAPI/service_kasir.dart';
import 'package:intl/intl.dart';
import 'package:trad/bottom_navigation_bar.dart';
import 'package:trad/Screen/KasirScreen/instan_kasir.dart';
import 'package:trad/Screen/KasirScreen/list_produk_kasir.dart';
import 'package:trad/Screen/KasirScreen/foto_qris.dart';
import 'package:trad/Screen/KasirScreen/nota_transaksi_list.dart'; // Import halaman NotaTransaksi
import 'package:trad/Screen/KasirScreen/nota_transaksi_instan.dart'; // Import halaman NotaTransaksiInstan


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  get userId => null;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Riwayat Transaksi',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: RiwayatTransaksi(idToko: userId,),
    );
  }
}

class RiwayatTransaksi extends StatefulWidget {
  final int idToko;

  RiwayatTransaksi({required this.idToko});

  @override
  _RiwayatTransaksiState createState() => _RiwayatTransaksiState();
}

class _RiwayatTransaksiState extends State<RiwayatTransaksi> {
  late Future<Map<String, dynamic>> _storeProfile;
  final ServiceKasir serviceKasir = ServiceKasir();
  final NumberFormat currencyFormat = NumberFormat('#,##0', 'id');

  @override
  void initState() {
    super.initState();
    _storeProfile = serviceKasir.getRiwayatTransaksiPerToko(widget.idToko.toString());
  }

  String formatCurrency(dynamic amount) {
    if (amount is String) {
      amount = double.tryParse(amount) ?? 0;
    }
    return currencyFormat.format(amount);
  }

  Color _getStatusBackgroundColor(String status) {
    switch (status.toLowerCase()) {
      case 'sukses':
        return Color.fromARGB(255, 184, 223, 187);
      case 'gagal':
        return Color.fromARGB(255, 232, 181, 181);
      default:
        return Colors.orange[100]!;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'sukses':
        return Color.fromARGB(255, 69, 175, 82);
      case 'gagal':
        return Color.fromARGB(255, 209, 62, 62);
      default:
        return Colors.orange;
    }
  }

  void _navigateToDetailPage(String jenisTransaksi, String idTransaksi) {
    if (jenisTransaksi == 'list_produk_toko') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NotaTransaksi(
            idTransaksi: idTransaksi, // The transaction ID
            idToko: widget.idToko, // The store ID that you need to provide
          ),
        ),
      );
    } else if (jenisTransaksi == 'bayar_instan') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NotaTransaksiInstan(
            idNota: idTransaksi, // The transaction ID
            idToko: widget.idToko, // The store ID that you need to provide
          ),
        ),
      );
    }
  }

  // void _handleApprove(String noNota) async {
  //   final response = await serviceKasir.transaksiApprove(noNota);
  //   if (response.containsKey('error')) {
  //     _showMessage(response['error']);
  //   } else {
  //     _showMessage('Transaksi berhasil disetujui.');
  //     setState(() {
  //       _storeProfile =
  //           serviceKasir.getRiwayatTransaksi(widget.idToko.toString());
  //     });
  //   }
  // }

  // void _handleReject(String noNota) async {
  //   final response = await serviceKasir.transaksiReject(noNota);
  //   if (response.containsKey('error')) {
  //     _showMessage(response['error']);
  //   } else {
  //     _showMessage('Transaksi berhasil ditolak.');
  //     setState(() {
  //       _storeProfile =
  //           serviceKasir.getRiwayatTransaksi(widget.idToko.toString());
  //     });
  //   }
  // }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
              'Riwayat Transaksi',
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
                future: _storeProfile,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Gagal memuat transaksi'));
                  } else if (!snapshot.hasData ||
                      snapshot.data == null ||
                      snapshot.data!['data'] == null) {
                    return Center(child: Text('Belum ada transaksi'));
                  } else {
                    final transaksiList =
                        snapshot.data!['data'] as List<dynamic>;
                    return ListView.builder(
  itemCount: transaksiList.length,
  itemBuilder: (context, index) {
    final transaksi = transaksiList[index];
    final status = transaksi['status'];
    final jenisTransaksi = transaksi['jenisTransaksi']; // Make sure this field exists in your data

    return InkWell(
      onTap: () {
        _navigateToDetailPage(
          jenisTransaksi,
          transaksi['id'].toString()
        );
      },
      child: Card(
                          margin: const EdgeInsets.only(bottom: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            side: BorderSide(
                              color: Color(0xFFD4D4D4),
                              width: 1.0,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                          color: _getStatusTextColor(status),
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
                                  mainAxisAlignment: MainAxisAlignment.start,
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
                                    // Row(
                                    //   children: [
                                    //     ElevatedButton(
                                    //       onPressed: () {
                                    //         _handleReject(transaksi['noNota']);
                                    //       },
                                    //       style: ElevatedButton.styleFrom(
                                    //         minimumSize: const Size(67, 40),
                                    //         fixedSize: const Size(91, 30),
                                    //         shape: RoundedRectangleBorder(
                                    //           borderRadius:
                                    //               BorderRadius.circular(6),
                                    //         ),
                                    //         backgroundColor: Colors.white,
                                    //         side: const BorderSide(
                                    //             color: Colors.red),
                                    //       ),
                                    //       child: const Text(
                                    //         'Batalkan',
                                    //         style: TextStyle(
                                    //           color: Colors.red,
                                    //           fontWeight: FontWeight.bold,
                                    //           fontSize: 10,
                                    //         ),
                                    //       ),
                                    //     ),
                                    //     const SizedBox(width: 8),
                                    //     ElevatedButton(
                                    //       onPressed: () {
                                    //         _handleApprove(transaksi['noNota']);
                                    //       },
                                    //       style: ElevatedButton.styleFrom(
                                    //         minimumSize: const Size(67, 40),
                                    //         fixedSize: const Size(91, 30),
                                    //         shape: RoundedRectangleBorder(
                                    //           borderRadius:
                                    //               BorderRadius.circular(6),
                                    //         ),
                                    //         backgroundColor:
                                    //             const Color(0xFF005466),
                                    //       ),
                                    //       child: const Text(
                                    //         'Terima',
                                    //         style: TextStyle(
                                    //           color: Colors.white,
                                    //           fontWeight: FontWeight.bold,
                                    //           fontSize: 10,
                                    //         ),
                                    //       ),
                                    //     ),
                                    //   ],
                                    // ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
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
            bottomNavigationBar: MyBottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          // Aksi navigasi ketika item ditekan
        },
        userId: widget.idToko,
      ),
    );
  }
}
