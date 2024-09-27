import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts package
import 'package:intl/intl.dart'; // Import intl package
import 'package:trad/Model/RestAPI/service_kasir.dart'; // Import the service class
import 'package:trad/Screen/KasirScreen/nota_instan.dart'; // Import NotaInstan screen

class TinjauPesananInstan extends StatefulWidget {
  final String namaToko;
  final int idToko; // Corrected to use idToko
  final double totalBelanja;
  final double bagiHasilPersenan;
  final double bagiHasil;
  final double nilaiVoucher;

  TinjauPesananInstan({
    required this.namaToko,
    required this.idToko, // Corrected to use idToko
    required this.totalBelanja,
    required this.bagiHasilPersenan,
    required this.bagiHasil,
    required this.nilaiVoucher,
  });

  @override
  _TinjauPesananInstanState createState() => _TinjauPesananInstanState();
}

class _TinjauPesananInstanState extends State<TinjauPesananInstan> {
  bool _isExpanded = false; // State for expanding or collapsing the section
  final ServiceKasir serviceKasir = ServiceKasir(); // Initialize the service

  double _biayaTambahanTunai = 0; // State for biaya tambahan tunai
  double _biayaTambahanVoucher = 0; // State for biaya tambahan voucher

  String _formatNumberWithThousandsSeparator(double number) {
    final format = NumberFormat("#,##0", "en_US");
    return format
        .format(number)
        .replaceAll(',', '.'); // Replace commas with dots
  }

  Future<void> _buatPesanan() async {
    // Call the service when 'Buat Pesanan' button is pressed
    final response = await serviceKasir.listBayarInstan(
      widget.idToko.toString(),
      widget.bagiHasilPersenan,
      widget.bagiHasil,
      widget.totalBelanja,
      widget.nilaiVoucher,
      _biayaTambahanTunai, // Pass biaya tambahan tunai
      _biayaTambahanVoucher, // Pass biaya tambahan voucher
    );

    // Print the response to debug
    print('API Response: $response');

    if (response.containsKey('error')) {
      _showMessage(response['error']);
    } else {
      // Use the 'id' from the response as 'idNota'
      final idNota =
          response['id'].toString(); // Convert to string if necessary

      // Check if idNota is not null and not empty
      if (idNota.isNotEmpty) {
        _showMessage('Pesanan berhasil dibuat!');

        // Navigate to the NotaInstan page with the valid idNota
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => NotaInstan(
              idNota: idNota,
              idToko: widget.idToko,
            ), // Pass the idNota to NotaInstan
          ),
        );
      } else {
        // Handle the case where idNota is null or empty
        _showMessage('Failed to create order: Invalid order ID.');
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    double grandTotal = widget.totalBelanja;
    double grandTotalVoucher = widget.nilaiVoucher;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF005466),
        title: const Text(
          'Tinjau Pesanan',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Input List Bayar Instan',
              style: GoogleFonts.openSans(
                color: const Color(0xFF005466),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildReadOnlyField('Total Belanja',
                _formatNumberWithThousandsSeparator(widget.totalBelanja)),
            const SizedBox(height: 16),
            _buildBagiHasilFields(),
            const SizedBox(height: 16),
            _buildReadOnlyField('Nilai Voucher',
                _formatNumberWithThousandsSeparator(widget.nilaiVoucher)),
            const Spacer(),
            _buildExpandableSummarySection(grandTotal, grandTotalVoucher),
            const SizedBox(height: 16),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF374151),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: TextEditingController(text: value),
          enabled: false,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFE8E8E8), // Set background color
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6.0),
              borderSide: const BorderSide(
                  color: Color(0xFFD1D5DB)), // Set outline color
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF9CA3AF), // Set text color
          ),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildBagiHasilFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bagi Hasil',
          style: GoogleFonts.openSans(
            color: const Color(0xFF374151),
            fontSize: 14,
            fontWeight: FontWeight.w600, // SemiBold
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: TextField(
                controller: TextEditingController(
                    text: widget.bagiHasilPersenan.toString()),
                textAlign: TextAlign.center,
                enabled: false,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFE8E8E8), // Set background color
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.0),
                    borderSide: const BorderSide(
                        color: Color(0xFFD1D5DB)), // Set outline color
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9CA3AF), // Set text color
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '% / Rp',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: TextField(
                controller: TextEditingController(
                    text:
                        _formatNumberWithThousandsSeparator(widget.bagiHasil)),
                enabled: false,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFE8E8E8), // Set background color
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.0),
                    borderSide: const BorderSide(
                        color: Color(0xFFD1D5DB)), // Set outline color
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9CA3AF), // Set text color
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExpandableSummarySection(
      double grandTotal, double grandTotalVoucher) {
    return Column(
      children: [
        Divider(
          color: Colors.grey[300],
          thickness: 1.0,
        ),
        if (_isExpanded)
          Column(
            children: [
              // Tambahkan code disini di atas Biaya Tambahan
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Text(
                          'Total Pesanan',
                          style: TextStyle(
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      Row(
                        children: [
                          SvgPicture.asset(
                            '/svg/icons/icons-money.svg',
                            width: 18,
                            height: 18,
                            color: Color(0xFF005466),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Rp. ${_formatNumberWithThousandsSeparator(grandTotal + _biayaTambahanTunai)}',
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
                            '${_formatNumberWithThousandsSeparator(grandTotalVoucher + _biayaTambahanVoucher)}',
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
              const SizedBox(
                  height: 8), // Optional untuk memberi jarak tambahan

              // Biaya Tambahan Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Biaya Tambahan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Open Sans',
                      color: Color(0xFF9CA3AF), // Text color
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
                          _biayaTambahanTunai = double.tryParse(value) ?? 0;
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
                      'assets/svg/icons/icons-voucher.svg', // Path to your SVG icon
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
                          _biayaTambahanVoucher = double.tryParse(value) ?? 0;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
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
                            '/svg/icons/icons-money.svg',
                            width: 18,
                            height: 18,
                            color: Color(0xFF005466),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Rp. ${_formatNumberWithThousandsSeparator(grandTotal + _biayaTambahanTunai)}',
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
                            '${_formatNumberWithThousandsSeparator(grandTotalVoucher + _biayaTambahanVoucher)}',
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

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.center, // Set the alignment to center
      children: [
        SizedBox(
          width: 154, // Set the fixed width
          child: OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF005466)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              minimumSize:
                  const Size(154, 40), // Set the minimum size (154xhug)
            ),
            child: const Text(
              'Batal',
              style: TextStyle(
                color: Color(0xFF005466),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 24), // Set space between the buttons
        SizedBox(
          width: 154, // Set the fixed width
          child: ElevatedButton(
            onPressed: _buatPesanan, // Call the service when button is pressed
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF005466),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              minimumSize:
                  const Size(154, 40), // Set the minimum size (154xhug)
            ),
            child: const Text(
              'Buat Pesanan',
              style: TextStyle(
                color: Color(0xFFF8F8F8),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
