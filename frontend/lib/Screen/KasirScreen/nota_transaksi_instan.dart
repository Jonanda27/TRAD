import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:trad/Model/RestAPI/service_kasir.dart';
import 'package:trad/Screen/KasirScreen/kasir_screen.dart'; // Import KasirScreen

class NotaTransaksiInstan extends StatefulWidget {
  final String idNota;
  final int idToko; // Corrected to use idToko

  NotaTransaksiInstan({required this.idNota, required this.idToko});

  @override
  _NotaTransaksiInstanState createState() => _NotaTransaksiInstanState();
}

class _NotaTransaksiInstanState extends State<NotaTransaksiInstan> {
  final ServiceKasir serviceKasir = ServiceKasir();
  Map<String, dynamic>? paymentDetails;
  bool isLoading = true;
  bool _isExpanded = false;
  String? errorMessage;
  bool isReadOnly = false;

  @override
  void initState() {
    super.initState();
    _fetchPaymentDetails();
  }

  Future<void> _fetchPaymentDetails() async {
    final response = await serviceKasir.getDetailNotaBayarInstan(widget.idNota);
    setState(() {
      isLoading = false;
      if (response.containsKey('error')) {
        errorMessage = response['error'];
      } else {
        paymentDetails = response;
      }
    });
  }

  String _formatNumberWithThousandsSeparator(dynamic number) {
    final format = NumberFormat("#,##0", "en_US");
    return format.format(double.parse(number.toString())).replaceAll(',', '.');
  }

  Color _getStatusBackgroundColor(String status) {
    switch (status.toLowerCase()) {
      case 'dalam proses':
        return const Color(0xFFFFF9DA);
      case 'belum dibayar':
        return const Color(0xFFD9D9D9);
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
      case 'dalam proses':
        return const Color(0xFFFF9900);
      case 'belum dibayar':
        return const Color(0xFF9CA3AF);
      case 'sukses':
        return Color.fromARGB(255, 69, 175, 82);
      case 'gagal':
        return Color.fromARGB(255, 209, 62, 62);
      default:
        return Colors.orange;
    }
  }

  void _handleApprove(String noNota) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.0),
          ),
          titlePadding: EdgeInsets.zero,
          title: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF337F8F),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(6.0),
              ),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              children: [
                Center(
                  child: const Text(
                    'Terima Transaksi',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          content: const Text(
            'Anda yakin ingin menyelesaikan transaksi berikut?',
            style: TextStyle(
              color: Color.fromARGB(255, 0, 0, 0),
            ),
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 108,
                  height: 36,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color(0xFF005466),
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF005466)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                    ),
                    child: const Text('Batal'),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                  ),
                ),
                const SizedBox(width: 15),
                SizedBox(
                  width: 108,
                  height: 36,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF337F8F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                    ),
                    child: const Text('Ya'),
                    onPressed: () async {
                      Navigator.of(context).pop(); // Close the dialog
                      final response =
                          await serviceKasir.transaksiApprove(noNota);
                      if (response.containsKey('error')) {
                        _showMessage(response['error']);
                      } else {
                        _showMessage('Transaksi berhasil disetujui.');
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => KasirScreen(
                              idToko: widget
                                  .idToko, // Pass the idToko to KasirScreen
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _handleReject(String noNota) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.0),
          ),
          titlePadding: EdgeInsets.zero,
          title: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF337F8F),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(6.0),
              ),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              children: [
                Center(
                  child: const Text(
                    'Tolak Transaksi',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          content: const Text(
            'Anda yakin ingin menolak transaksi berikut?',
            style: TextStyle(
              color: Color.fromARGB(255, 0, 0, 0),
            ),
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 108,
                  height: 36,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color(0xFF005466),
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF005466)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                    ),
                    child: const Text('Batal'),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                  ),
                ),
                const SizedBox(width: 15),
                SizedBox(
                  width: 108,
                  height: 36,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFFEF4444),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                    ),
                    child: const Text('Ya'),
                    onPressed: () async {
                      Navigator.of(context).pop(); // Close the dialog
                      final response =
                          await serviceKasir.transaksiReject(noNota);
                      if (response.containsKey('error')) {
                        _showMessage(response['error']);
                      } else {
                        _showMessage('Transaksi berhasil ditolak.');
                        setState(() {
                          _fetchPaymentDetails(); // Refresh the payment details
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(0, 84, 102, 1),
        title: const Text('Detail Transaksi',
            style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        'assets/img/bekgron.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                paymentDetails?['namaToko'] ?? '',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusBackgroundColor(
                                      paymentDetails?['status'] ??
                                          'Status tidak tersedia'),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  paymentDetails?['status'] ??
                                      'Status tidak tersedia',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: _getStatusTextColor(
                                        paymentDetails?['status'] ??
                                            'Status tidak tersedia'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${paymentDetails?['tanggal']} - ${paymentDetails?['waktu']}',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  'Merchant: ${paymentDetails?['namaMerchant'] ?? '-'}'),
                              Text(
                                  'Pembeli: ${paymentDetails?['namaPembeli'] ?? '-'}'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Kode Pembayaran:',
                                    style: TextStyle(
                                      color: Color(0xFF005466),
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        paymentDetails?['noNota'] ?? '',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: SvgPicture.asset(
                                          'assets/svg/icons/icons-copy.svg', // Adjust the path to your SVG file
                                          height:
                                              16, // Set the desired height for the SVG icon
                                          width:
                                              16, // Set the desired width for the SVG icon
                                        ),
                                        onPressed: () {
                                          // Ambil nomor nota yang ingin disalin
                                          String nomorNota = paymentDetails?[
                                                  'noNota'] ??
                                              ''; // Ganti dengan kunci yang sesuai untuk nomor nota

                                          // Salin nomor nota ke clipboard
                                          Clipboard.setData(ClipboardData(
                                                  text: nomorNota))
                                              .then((_) {
                                            // Tampilkan pesan atau snackbar untuk memberi tahu pengguna bahwa nomor telah disalin
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Nomor nota berhasil disalin: $nomorNota'),
                                              ),
                                            );
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 30,
                                child: ElevatedButton(
                                  onPressed: () {
                                    _showQRPopup(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    side: BorderSide(color: Color(0xFF005466)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.qr_code,
                                          color: Color(0xFF005466), size: 16),
                                      SizedBox(width: 2),
                                      Text(
                                        'Tampilkan QR',
                                        style: TextStyle(
                                          color: Color(0xFF005466),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildPaymentDetails(),
                          const Spacer(),
                          _buildExpandableSummarySection(),
                          const SizedBox(height: 16),
                          _buildActionButtons(),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildPaymentDetails() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow(
              'Total Belanja', paymentDetails?['totalBelanjaTunai']),
          _buildDetailRow('Voucher  ', paymentDetails?['totalBelanjaVoucher']),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF005466),
              fontSize: 14,
            ),
          ),
          Text(
            'Rp ${_formatNumberWithThousandsSeparator(value ?? 0.0)},-',
            style: const TextStyle(
              color: Color(0xFF005466),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableSummarySection() {
    double grandTotal =
        double.tryParse(paymentDetails?['totalBelanjaTunai'] ?? '0.0') ?? 0.0;
    double grandTotalVoucher =
        double.tryParse(paymentDetails?['totalBelanjaVoucher'] ?? '0.0') ?? 0.0;
     double biayaTambahanTunai =
        double.tryParse(paymentDetails?['biayaTambahanTunai'] ?? '0.0') ?? 0.0;
    double biayaTambahanVoucher =
        double.tryParse(paymentDetails?['biayaTambahanVoucher'] ?? '0.0') ?? 0.0;

    double adjustedGrandTotal = grandTotal - biayaTambahanTunai;
    double adjustedGrandTotalVoucher = grandTotalVoucher - biayaTambahanVoucher;

    return Column(
      children: [
        Divider(
          color: Colors.grey[300],
          thickness: 1.0,
        ),
        if (_isExpanded)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Pesanan',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7B8794),
                          ),
                        ),
                        Row(
                          children: [
                            const SizedBox(width: 4),
                            Text(
                              'Rp. ${adjustedGrandTotal.toString()},-',
                              style: const TextStyle(
                                color: Color(0xFF005466),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 130),
                            SvgPicture.asset(
                              'assets/svg/icons/icons-voucher.svg',
                              width: 18,
                              height: 18,
                              color: Color(0xFF005466),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${adjustedGrandTotalVoucher.toString()}',
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
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Biaya Tambahan',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Open Sans',
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Rp. ${(paymentDetails!['biayaTambahanTunai'] != null) ? double.tryParse(paymentDetails!['biayaTambahanTunai'].toString())?.toStringAsFixed(0) ?? '0' : '0'}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF005466),
                      ),
                    ),
                    const SizedBox(width: 130),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: SvgPicture.asset(
                        'assets/svg/icons/icons-voucher.svg',
                        width: 20,
                        height: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      ' ${(paymentDetails!['biayaTambahanVoucher'] != null) ? double.tryParse(paymentDetails!['biayaTambahanVoucher'].toString())?.toStringAsFixed(0) ?? '0' : '0'}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF005466),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
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
                            'Rp. ${grandTotal.toString()},-',
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
                            '${grandTotalVoucher.toString()}',
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
              IconButton(
                icon: Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Color(0xFF005466),
                ),
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    bool isBelumDibayar =
        paymentDetails?['status']?.toLowerCase() == 'dalam proses';
    bool isCompleted = paymentDetails?['status']?.toLowerCase() == 'sukses' ||
        paymentDetails?['status']?.toLowerCase() == 'gagal';

    if (isCompleted) {
      return SizedBox
          .shrink(); // Return an empty widget if the status is "Sukses" or "Gagal"
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: () {
              _handleReject(paymentDetails?['noNota'] ?? '');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              side: BorderSide(color: Colors.red),
              minimumSize: Size(150, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text(
              'Batalkan',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _handleApprove(paymentDetails?['noNota'] ?? '');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isBelumDibayar ? Color(0xFF005466) : Color(0xFFE0E0E0),
              minimumSize: Size(150, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(
              'Terima',
              style: TextStyle(
                color: isBelumDibayar ? Colors.white : Color(0xFF9E9E9E),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQRPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                paymentDetails?['noNota'] ?? 'QR Code tidak tersedia',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF005466),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              paymentDetails?['noNota'] != null
                  ? PrettyQr(
                      data: paymentDetails!['noNota'],
                      size: 200,
                      roundEdges: true,
                      errorCorrectLevel: QrErrorCorrectLevel.M,
                    )
                  : const Center(
                      child: Text('Kode Pembayaran tidak tersedia'),
                    ),
              const SizedBox(height: 24),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Tutup',
                style: TextStyle(color: Color(0xFF005466)),
              ),
            ),
          ],
        );
      },
    );
  }
}
