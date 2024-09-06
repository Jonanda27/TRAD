import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trad/Screen/KasirScreen/instan_kasir.dart';
import 'package:trad/Screen/KasirScreen/list_produk_kasir.dart';
import 'package:trad/Screen/KasirScreen/foto_qris.dart'; // Import halaman FotoQris
import 'package:trad/Screen/KasirScreen/nota_transaksi.dart';
import 'package:trad/bottom_navigation_bar.dart';
import 'package:trad/Model/RestAPI/service_kasir.dart'; // Import ServiceKasir class
import 'package:intl/intl.dart';

class KasirScreen extends StatefulWidget {
  final int idToko; // Parameter idToko

  KasirScreen({required this.idToko});

  @override
  _KasirScreenState createState() => _KasirScreenState();
}

class _KasirScreenState extends State<KasirScreen> {
  late Future<Map<String, dynamic>> _storeProfile;
  final ServiceKasir serviceKasir = ServiceKasir(); // Inisialisasi Service
  final NumberFormat currencyFormat = NumberFormat('#,##0', 'id');

  @override
  void initState() {
    super.initState();
    _storeProfile = serviceKasir.getTransaksiByToko(widget.idToko.toString());
  }

  String formatCurrency(dynamic amount) {
    if (amount is String) {
      amount = double.tryParse(amount) ?? 0;
    }
    return currencyFormat.format(amount);
  }

  void _handleApprove(String noNota) async {
    final response = await serviceKasir.transaksiApprove(noNota);
    if (response.containsKey('error')) {
      _showMessage(response['error']);
    } else {
      _showMessage('Transaksi berhasil disetujui.');
      setState(() {
        _storeProfile =
            serviceKasir.getTransaksiByToko(widget.idToko.toString());
      });
    }
  }

  void _handleReject(String noNota) async {
    final response = await serviceKasir.transaksiReject(noNota);
    if (response.containsKey('error')) {
      _showMessage(response['error']);
    } else {
      _showMessage('Transaksi berhasil ditolak.');
      setState(() {
        _storeProfile =
            serviceKasir.getTransaksiByToko(widget.idToko.toString());
      });
    }
  }

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
              'Kasir',
              style: TextStyle(
                color: Color(0xFF005466),
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'OpenSans',
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<Map<String, dynamic>>(
              future: _storeProfile,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Gagal memuat data toko');
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return Text('Toko tidak ditemukan');
                } else {
                  final profileData = snapshot.data!;
                  final namaToko =
                      profileData['namaToko'] ?? 'Nama tidak tersedia';
                  final fotoQrToko = profileData['fotoQrToko'];

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
                        Text(
                          namaToko,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'OpenSans',
                          ),
                        ),
                        fotoQrToko == null
                            ? TextButton(
                                onPressed: () {
                                  // Aksi untuk menambah QR toko
                                },
                                child: const Text(
                                  'Tambah QR Toko',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'OpenSans',
                                  ),
                                ),
                              )
                            : ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FotoQris(
                                        idToko: widget.idToko.toString(),
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Color(0xFF005466),
                                  backgroundColor: Colors.white,
                                ),
                                child: const Text(
                                  'QR Toko',
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
            // Bagian "Buat List Bayar"
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  'Buat List Bayar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF005466),
                    fontFamily: 'OpenSans',
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(
                    Icons.info_outline,
                    color: Colors.grey,
                    size: 18,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          titlePadding: EdgeInsets.zero,
                          title: Container(
                            color: Color(0xFF005466),
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.info, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      'Buat List Bayar',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'OpenSans',
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.white),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ),
                          ),
                          content: const Text(
                            'Gunakan pilihan List Produk untuk nota yang lebih detail, dan pilihan Instan untuk membuat nota Instan',
                            style: TextStyle(
                              color: Colors.black87,
                              fontFamily: 'OpenSans',
                            ),
                          ),
                        );
                      },
                    );
                  },
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
                                ListProdukKasir(id: widget.idToko),
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
                              'List Produk',
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
                            builder: (context) =>
                                InstanKasir(idToko: widget.idToko),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: const [
                            Icon(
                              Icons.check_box,
                              color: Color(0xFF006064),
                              size: 32,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Instan',
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
            // Bagian untuk menampilkan transaksi
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
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => NotaTransaksi(
                                        idTransaksi: transaksi['id'].toString(), // Pass the transaction ID
                                      ),
                                    ),
                                  );
                                },
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
                                              color: Colors.orange[100],
                                              borderRadius:
                                                  BorderRadius.circular(4.0),
                                            ),
                                            child: Text(
                                              transaksi['status'],
                                              style: TextStyle(
                                                color: Colors.orange,
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
                                      const Divider(
                                          color: Colors
                                              .grey), // Divider tambahan di bawah tanggal dan jam pembayaran
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
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                          Row(
                                            children: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  _handleReject(transaksi[
                                                      'noNota']); // Aksi untuk membatalkan transaksi
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  minimumSize: const Size(67,
                                                      40), // Lebar tetap 67 dan tinggi hug
                                                  fixedSize: const Size(91, 30),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(6),
                                                  ),
                                                  backgroundColor: Colors.white,
                                                  side: const BorderSide(
                                                      color: Colors.red),
                                                ),
                                                child: const Text(
                                                  'Batalkan',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        10, // Set smaller font size
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              ElevatedButton(
                                                onPressed: () {
                                                  _handleApprove(transaksi[
                                                      'noNota']); // Aksi untuk menerima transaksi
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  minimumSize: const Size(67,
                                                      40), // Lebar tetap 67 dan tinggi hug
                                                  fixedSize: const Size(91, 30),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(6),
                                                  ),
                                                  backgroundColor:
                                                      const Color(0xFF005466),
                                                ),
                                                child: const Text(
                                                  'Terima',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        10, // Set smaller font size
                                                  ),
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
      bottomNavigationBar: MyBottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          // Aksi navigasi ketika item ditekan
        },
        userId: widget.idToko,
      ),
    );
  }
}
