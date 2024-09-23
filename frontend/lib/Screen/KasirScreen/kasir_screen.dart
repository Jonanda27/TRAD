import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trad/Model/RestAPI/service_toko.dart';
import 'package:trad/Model/toko_model.dart';
import 'package:trad/Screen/KasirScreen/instan_kasir.dart';
import 'package:trad/Screen/KasirScreen/list_produk_kasir.dart';
import 'package:trad/Screen/KasirScreen/foto_qris.dart';
import 'package:trad/Screen/KasirScreen/nota_transaksi_list.dart'; // Import halaman NotaTransaksi
import 'package:trad/Screen/KasirScreen/nota_transaksi_instan.dart'; // Import halaman NotaTransaksiInstan
import 'package:trad/Screen/TokoScreen/edit_toko.dart';
import 'package:trad/bottom_navigation_bar.dart';
import 'package:trad/Model/RestAPI/service_kasir.dart';
import 'package:intl/intl.dart';

class KasirScreen extends StatefulWidget {
  final int idToko;

  KasirScreen({required this.idToko});

  @override
  _KasirScreenState createState() => _KasirScreenState();
}

class _KasirScreenState extends State<KasirScreen> {
  late Future<Map<String, dynamic>> _storeProfile;
  final ServiceKasir serviceKasir = ServiceKasir();
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

  void _navigateToUbahToko() async {
    try {
      // Create an instance of TokoService
      final TokoService tokoService = TokoService();

      // Fetch all stores
      final List<TokoModel> stores = await tokoService.fetchStores();

      // Find the store that matches the given id
      final TokoModel? toko = stores.firstWhere(
        (store) => store.id == widget.idToko,
        orElse: () => TokoModel(
          id: widget.idToko,
          userId: -1,
          fotoProfileToko: '',
          fotoQrToko: '',
          fotoToko: [],
          namaToko: 'Toko Tidak Ditemukan',
          kategoriToko: {},
          alamatToko: '',
          nomorTeleponToko: '',
          emailToko: '',
          deskripsiToko: '',
          provinsiToko: '',
          kotaToko: '',
          jamOperasional: [],
        ),
      );

      if (toko != null && toko.id != -1) {
        // Navigate to UbahTokoScreen with the found store
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UbahTokoScreen(
              toko: toko,
              idToko: widget.idToko,
            ),
          ),
        );
      } else {
        _showMessage('Toko tidak ditemukan.');
      }
    } catch (e) {
      _showMessage('Gagal memuat detail toko: $e');
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
                                onPressed:
                                    _navigateToUbahToko, // Navigate to UbahTokoScreen
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
                const SizedBox(width: 2),
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
                        final jenisTransaksi =
                            transaksi['jenisTransaksi']; // Ambil jenisTransaksi

                        // Cek apakah status adalah 'dalam proses' atau 'belum dibayar'
                        final isBelumDibayar = status.toLowerCase() == 'dalam proses';

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
                                  _navigateToDetailPage(
                                      jenisTransaksi,
                                      transaksi['id']
                                          .toString()); // Cek jenisTransaksi dan navigasi ke halaman yang sesuai
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
                                          Row(
                                            children: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  _handleReject(
                                                      transaksi['noNota']);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  minimumSize:
                                                      const Size(67, 40),
                                                  fixedSize: const Size(91, 30),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
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
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              ElevatedButton(
                                                onPressed: () {
                                                  _handleApprove(
                                                      transaksi['noNota']);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  minimumSize:
                                                      const Size(67, 40),
                                                  fixedSize: const Size(91, 30),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                  ),
                                                  backgroundColor:
                                                      isBelumDibayar
                                                          ? const Color(0xFF005466)
                                                          : const Color(0xFFE0E0E0),
                                                ),
                                                child: Text(
                                                  'Terima',
                                                  style: TextStyle(
                                                    color: isBelumDibayar
                                                        ? Colors.white
                                                        : const Color(0xFF9E9E9E),
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    fontSize: 10,
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
