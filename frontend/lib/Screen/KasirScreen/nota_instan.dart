import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts package
import 'package:intl/intl.dart'; // Import intl package
import 'package:trad/Model/RestAPI/service_kasir.dart'; // Import your service class

class NotaInstan extends StatefulWidget {
  final String idNota;

  NotaInstan({required this.idNota});

  @override
  _NotaInstanState createState() => _NotaInstanState();
}

class _NotaInstanState extends State<NotaInstan> {
  final ServiceKasir serviceKasir = ServiceKasir();
  Map<String, dynamic>? paymentDetails;
  bool isLoading = true;
  bool _isExpanded = false; // State for expanding or collapsing the section
  String? errorMessage;

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
          content: FutureBuilder<Map<String, dynamic>>(
            future: serviceKasir.getTransaksiByToko(idToko),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!['fotoQrToko'] == null) {
                return const Center(child: Text('QR Toko tidak tersedia'));
              } else {
                final data = snapshot.data!;
                final String? base64Image = data['fotoQrToko'];

                Uint8List? qrImageBytes;
                if (base64Image != null && base64Image.isNotEmpty) {
                  qrImageBytes = base64Decode(base64Image);
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      data['namaToko'] ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF005466),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    if (qrImageBytes != null)
                      Image.memory(
                        qrImageBytes,
                        width: 220,
                        height: 220,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.image_not_supported,
                            size: 100,
                            color: Colors.grey,
                          );
                        },
                      )
                    else
                      const Center(child: Text('QR Toko tidak tersedia')),
                    const SizedBox(height: 24),
                  ],
                );
              }
            },
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        paymentDetails?['namaToko'] ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${paymentDetails?['tanggalPembayaran']} - ${paymentDetails?['jamPembayaran']}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Merchant: ${paymentDetails?['namaMerchant'] ?? '-'}'),
                          Text('Pembeli: ${paymentDetails?['namaPembeli'] ?? '-'}'),
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
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 16),
                            onPressed: () {
                              // Copy to clipboard functionality
                            },
                          ),
                        ],
                      ),
                      Text(
                        paymentDetails?['noNota'] ?? '',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildPaymentDetails(),
                      const Divider(),
                      _buildExpandableSummarySection(),
                      const SizedBox(height: 16),
                      _buildActionButtons(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildPaymentDetails() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Total Belanja', paymentDetails?['totalBelanjaTunai']),
          _buildDetailRow('Voucher (5%)', paymentDetails?['totalBelanjaVoucher']),
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
    double grandTotal = double.tryParse(paymentDetails?['totalBelanjaTunai'] ?? '0.0') ?? 0.0;
    double grandTotalVoucher = double.tryParse(paymentDetails?['totalBelanjaVoucher'] ?? '0.0') ?? 0.0;

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
                          'Total Pesanan ',
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
                            const SizedBox(width: 130),
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
                // Additional rows for fees or discounts
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
                      const Text('Total Pembayaran', style: TextStyle(fontWeight: FontWeight.bold)),
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
                      const Text('', style: TextStyle(fontWeight: FontWeight.bold)),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: () {
            _showQRPopup(context, paymentDetails?['idToko'].toString() ?? '');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF005466),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            minimumSize: const Size(160, 40),
          ),
          child: const Text(
            'Tampilkan QR',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        OutlinedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFF005466)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            minimumSize: const Size(120, 40),
          ),
          child: const Text(
            'Kembali',
            style: TextStyle(
              color: Color(0xFF005466),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
