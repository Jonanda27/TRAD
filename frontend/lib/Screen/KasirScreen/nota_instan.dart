import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart'; // Import intl package for number formatting
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:trad/Model/RestAPI/service_kasir.dart';
import 'package:trad/Screen/KasirScreen/kasir_screen.dart'; // Import your service class

class NotaInstan extends StatefulWidget {
  final String idNota;
  final int idToko;

  NotaInstan({required this.idNota, required this.idToko});

  @override
  _NotaInstanState createState() => _NotaInstanState();
}

class _NotaInstanState extends State<NotaInstan> {
  final ServiceKasir serviceKasir = ServiceKasir();
  Map<String, dynamic>? paymentDetails;
  bool isLoading = true;
  bool _isExpanded = false; // State for expanding or collapsing the section
  String? errorMessage;
  double additionalFee = 0.0; // Additional fee
  double additionalVoucher = 0.0; // Additional voucher

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

  void _showQRPopup(BuildContext context, String idToko) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          content: paymentDetails?['noNota'] != null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Kode Pembayaran: ${paymentDetails!['noNota']}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF005466),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    PrettyQr(
                      data: paymentDetails!['noNota'],
                      size: 200,
                      roundEdges: true,
                      errorCorrectLevel: QrErrorCorrectLevel.M,
                    ),
                    const SizedBox(height: 24),
                  ],
                )
              : const Center(
                  child: Text('QR Code tidak tersedia'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/img/bekgron.png', // Use bekgron.png as the background
              fit: BoxFit.cover,
            ),
          ),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
                  ? Center(child: Text(errorMessage!))
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Nama Toko
                              Text(
                                paymentDetails?['namaToko'] ?? '',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              // Status
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Color(0xFFD9D9D9), // Background color
                                  borderRadius: BorderRadius.circular(
                                      8), // Rounded corners
                                ),
                                child: Text(
                                  paymentDetails?['status'] ??
                                      'Status tidak tersedia',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF9CA3AF), // Text color
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
                              RichText(
                                text: TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'Merchant: ',
                                      style: TextStyle(
                                        color: Color(
                                            0xFF9CA3AF), // Warna untuk label "Merchant"
                                        fontSize: 14,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          '${paymentDetails?['namaMerchant']}',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize:
                                            14, // Warna untuk data merchant
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                  height:
                                      4), // Tambahkan jarak antara Merchant dan Pembeli
                              RichText(
                                text: TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'Pembeli: ',
                                      style: TextStyle(
                                        color: Color(
                                            0xFF9CA3AF), // Warna untuk label "Pembeli"
                                        fontSize: 14,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          '${paymentDetails?['namaPembeli'] ?? '-'}',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize:
                                            14, // Warna untuk data pembeli
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Divider(),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'Kode Pembayaran:',
                                style: TextStyle(
                                  color: Color(0xFF005466),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  paymentDetails?['noNota'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy, size: 16),
                                padding: EdgeInsets
                                    .zero, // Remove any padding around the icon
                                onPressed: () {
                                  // Ambil nomor nota yang ingin disalin
                                  String nomorNota =
                                      paymentDetails?['noNota'] ?? '';

                                  // Salin nomor nota ke clipboard
                                  Clipboard.setData(
                                          ClipboardData(text: nomorNota))
                                      .then((_) {
                                    // Tampilkan pesan atau snackbar untuk memberi tahu pengguna bahwa nomor telah disalin
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Nomor nota berhasil disalin: $nomorNota'),
                                      ),
                                    );
                                  });
                                },
                              ),
                              const SizedBox(
                                width: 120,
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),
                          _buildPaymentDetails(),
                          const Spacer(),
                          _buildExpandableSummarySection(),
                          const SizedBox(height: 16),
                          _buildActionButtons(), // Updated action buttons
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow(
              'Total Belanja', paymentDetails?['totalBelanjaTunai']),
          _buildDetailRow(
              'Voucher (5%)', paymentDetails?['totalBelanjaVoucher']),
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
                              'Rp. ${grandTotal.toString()},-',
                              style: const TextStyle(
                                color: Color(0xFF005466),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 65),
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
                const SizedBox(height: 8),
                // Additional Fee Section
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
                    const Text(
                      'Rp.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF005466),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: (paymentDetails?['biayaTambahanTunai'] !=
                                  null)
                              ? '${double.tryParse(paymentDetails!['biayaTambahanTunai'].toString())?.toStringAsFixed(0) ?? '0'}' // Mengkonversi ke double dan menghilangkan .00
                              : '0',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onChanged: (value) {
                          setState(() {
                            additionalFee = double.tryParse(value) ?? 0.0;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 21),
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
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: '0',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onChanged: (value) {
                          setState(() {
                            additionalVoucher = double.tryParse(value) ?? 0.0;
                          });
                        },
                      ),
                    ),
                  ],
                ),
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
                            'Rp. ${(grandTotal + additionalFee).toString()},-',
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
                            '${(grandTotalVoucher + additionalVoucher).toString()}',
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
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () {
            _showQRPopup(context, widget.idToko.toString());
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF005466),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: const Icon(Icons.qr_code, color: Colors.white),
          label:
              const Text('Tampilkan QR', style: TextStyle(color: Colors.white)),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => KasirScreen(idToko: widget.idToko),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color.fromRGBO(0, 84, 102, 1),
            side: const BorderSide(color: Color.fromRGBO(0, 84, 102, 1)),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Kembali'),
        ),
      ],
    );
  }
}
