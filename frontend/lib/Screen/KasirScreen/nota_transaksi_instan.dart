import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:trad/Model/RestAPI/service_kasir.dart';

class NotaTransaksiInstan extends StatefulWidget {
  final String idNota;
  final int idToko; // Corrected to use idToko

  NotaTransaksiInstan({required this.idNota,required this.idToko});

  @override
  _NotaTransaksiInstanState createState() => _NotaTransaksiInstanState();
}

class _NotaTransaksiInstanState extends State<NotaTransaksiInstan> {
  final ServiceKasir serviceKasir = ServiceKasir();
  Map<String, dynamic>? paymentDetails;
  bool isLoading = true;
  bool _isExpanded = false;
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
                                  color: const Color(0xFFFFF9DA),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  paymentDetails?['status'] ??
                                      'Status tidak tersedia',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFF9900),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${paymentDetails?['tanggalPembayaran']} - ${paymentDetails?['jamPembayaran']}',
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
                                        icon: const Icon(Icons.copy, size: 16),
                                        onPressed: () {
                                          // Logic to copy the payment code
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
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.qr_code, color: Color(0xFF005466), size: 16),
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
                          'Total Pembayaran',
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: () {
              // Logic to cancel the transaction
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
              // Logic to accept the transaction
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFE0E0E0),
              minimumSize: Size(150, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text(
              'Terima',
              style: TextStyle(
                color: Color(0xFF9E9E9E),
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
