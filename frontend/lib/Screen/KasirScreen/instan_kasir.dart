import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts package
import 'package:intl/intl.dart'; // Import intl package
import 'package:trad/Model/RestAPI/service_kasir.dart'; // Import ServiceKasir class
import 'tinjau_pesanan_instan.dart'; // Import TinjauPesananInstan page

class InstanKasir extends StatefulWidget {
  final int idToko;

  InstanKasir({required this.idToko});

  @override
  _InstanKasirState createState() => _InstanKasirState();
}

class _InstanKasirState extends State<InstanKasir> {
  final TextEditingController _totalBelanjaController = TextEditingController();
  final TextEditingController _bagiHasilPersenanController =
      TextEditingController();
  final TextEditingController _bagiHasilController = TextEditingController();
  final TextEditingController _nilaiVoucherController = TextEditingController();

  final ServiceKasir serviceKasir = ServiceKasir(); // Initialize the service

  bool _isButtonEnabled = false;
  String? namaToko; // Variable to store the fetched store name

  @override
  void initState() {
    super.initState();
    // Fetch the store data
    _fetchStoreData();
    
    // Listen to changes in the text fields
    _totalBelanjaController.addListener(_onInputChanged);
    _bagiHasilPersenanController.addListener(_onInputChanged);
    _bagiHasilController.addListener(_checkIfButtonShouldBeEnabled);
    _nilaiVoucherController.addListener(_checkIfButtonShouldBeEnabled);
  }

  void _fetchStoreData() async {
    // Fetch the store data using the service
    final response = await serviceKasir.getTransaksiByToko(widget.idToko.toString());
    if (response.containsKey('error')) {
      _showMessage(response['error']);
    } else {
      setState(() {
        namaToko = response['namaToko'] ?? 'Nama tidak tersedia';
      });
    }
  }

  @override
  void dispose() {
    _totalBelanjaController.dispose();
    _bagiHasilPersenanController.dispose();
    _bagiHasilController.dispose();
    _nilaiVoucherController.dispose();
    super.dispose();
  }

  void _onInputChanged() {
    String totalBelanjaText = _totalBelanjaController.text.replaceAll('.', '');
    double totalBelanja = double.tryParse(totalBelanjaText) ?? 0.0;
    final bagiHasilPersen =
        double.tryParse(_bagiHasilPersenanController.text) ?? 0.0;

    if (totalBelanja > 0) {
      // Format total belanja with thousands separators
      _totalBelanjaController.value = TextEditingValue(
        text: _formatNumberWithThousandsSeparator(totalBelanja),
        selection: TextSelection.collapsed(
            offset: _formatNumberWithThousandsSeparator(totalBelanja).length),
      );
    }

    if (totalBelanja > 0 && bagiHasilPersen > 0) {
      final bagiHasil = totalBelanja * (bagiHasilPersen / 100);
      final nilaiVoucher = 2 * bagiHasil;

      // Format with thousands separators
      _bagiHasilController.text = _formatNumberWithThousandsSeparator(bagiHasil);
      _nilaiVoucherController.text =
          _formatNumberWithThousandsSeparator(nilaiVoucher);
    } else {
      _bagiHasilController.clear();
      _nilaiVoucherController.clear();
    }

    _checkIfButtonShouldBeEnabled();
  }

  String _formatNumberWithThousandsSeparator(double number) {
    final format = NumberFormat("#,##0", "en_US"); // Use Indonesian locale format
    return format.format(number).replaceAll(',', '.'); // Replace commas with dots
  }

  void _checkIfButtonShouldBeEnabled() {
    setState(() {
      _isButtonEnabled = _totalBelanjaController.text.isNotEmpty &&
          _bagiHasilPersenanController.text.isNotEmpty &&
          _bagiHasilController.text.isNotEmpty &&
          _nilaiVoucherController.text.isNotEmpty;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

void _navigateToTinjauPesananInstan() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => TinjauPesananInstan(
        namaToko: namaToko ?? 'Nama tidak tersedia',
        idToko: widget.idToko, // Add the idToko parameter here
        totalBelanja: double.tryParse(_totalBelanjaController.text.replaceAll('.', '')) ?? 0.0,
        bagiHasilPersenan: double.tryParse(_bagiHasilPersenanController.text) ?? 0.0,
        bagiHasil: double.tryParse(_bagiHasilController.text.replaceAll('.', '')) ?? 0.0,
        nilaiVoucher: double.tryParse(_nilaiVoucherController.text.replaceAll('.', '')) ?? 0.0,
      ),
    ),
  );
}


  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white, // Set background color of the page to white
    appBar: AppBar(
      backgroundColor: const Color.fromRGBO(0, 84, 102, 1),
      title: Text(
        namaToko ?? '',
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
              fontWeight: FontWeight.bold, // Bold
            ),
          ),
          const SizedBox(height: 16),
          _buildInputField('Total Belanja', _totalBelanjaController),
          const SizedBox(height: 16),
          _buildBagiHasilFields(),
          const SizedBox(height: 16),
          _buildNilaiVoucherField(),
          const Spacer(),
          Divider(color: Color(0xFFD1D5DB)), // Add a divider above the button
          Align(
            alignment: Alignment.bottomRight,
            child: TextButton(
              onPressed: _isButtonEnabled ? _navigateToTinjauPesananInstan : null,
              style: TextButton.styleFrom(
                backgroundColor: _isButtonEnabled ? Color(0xFF005466) : Color(0xFFD1D5DB), // Dynamic background color
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                'Selanjutnya',
                style: TextStyle(
                  color: _isButtonEnabled ? Color(0xFFF8F8F8) : Color(0xFF9CA3AF), // Dynamic text color
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildInputField(String label, TextEditingController controller,
    {bool enabled = true}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: Color(0xFF1F2937),
          fontSize: 14, // Ubah ukuran font menjadi 18
          fontWeight: FontWeight.w600, // Set font menjadi semi-bold
        ),
      ),
      const SizedBox(height: 4),
      TextField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          hintText: '100.000',
          hintStyle: TextStyle(color: const Color(0xFFD1D5DB)), // Mengubah warna hintText
          filled: true, // Set filled to true for white background
          fillColor: Colors.white, // Background color for the TextField
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.0),
            borderSide: const BorderSide(
              color: Color(0xFFD1D5DB),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.0),
            borderSide: const BorderSide(
              color: Color(0xFFD1D5DB),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.0),
            borderSide: const BorderSide(
              color: Color(0xFFD1D5DB),
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),
        style: TextStyle(
          fontSize: 14,
          color: enabled ? Colors.black : const Color(0xFF9CA3AF),
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
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 4),
      Row(
        children: [
          Expanded(
            flex: 1,
            child: TextField(
              controller: _bagiHasilPersenanController,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '5',
                hintStyle: TextStyle(color: const Color(0xFFD1D5DB)), // Mengubah warna hintText
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6.0),
                  borderSide: const BorderSide(
                    color: Color(0xFFD1D5DB),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6.0),
                  borderSide: const BorderSide(
                    color: Color(0xFFD1D5DB),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6.0),
                  borderSide: const BorderSide(
                    color: Color(0xFFD1D5DB),
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
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
              controller: _bagiHasilController,
              decoration: InputDecoration(
                hintText: '5.000',
                hintStyle: TextStyle(color: const Color(0xFFD1D5DB)), // Mengubah warna hintText
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6.0),
                  borderSide: const BorderSide(
                    color: Color(0xFFD1D5DB),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6.0),
                  borderSide: const BorderSide(
                    color: Color(0xFFD1D5DB),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6.0),
                  borderSide: const BorderSide(
                    color: Color(0xFFD1D5DB),
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              keyboardType: TextInputType.number,
            ),
          ),
        ],
      ),
    ],
  );
}

Widget _buildNilaiVoucherField() {
  return Row(
    children: [
      Text(
        'Nilai Voucher',
        style: GoogleFonts.openSans(
          color: const Color(0xFF374151),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: TextField(
          controller: _nilaiVoucherController,
          decoration: InputDecoration(
            hintText: '10.000',
            hintStyle: TextStyle(color: const Color(0xFFD1D5DB)), // Mengubah warna hintText
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6.0),
              borderSide: const BorderSide(
                color: Color(0xFFD1D5DB),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6.0),
              borderSide: const BorderSide(
                color: Color(0xFFD1D5DB),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6.0),
              borderSide: const BorderSide(
                color: Color(0xFFD1D5DB),
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          keyboardType: TextInputType.number,

        ),
      ),
    ],
  );
}

}
