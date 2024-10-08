import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool _isUpdatingBagiHasil = false;
  bool _isUpdatingBagiHasilPersen = false;
  bool _isUpdatingNilaiVoucher = false;

  @override
  void initState() {
    super.initState();
    // Fetch the store data
    _fetchStoreData();

    _totalBelanjaController.addListener(_onInputChanged);
    _bagiHasilPersenanController.addListener(
        _onInputChanged); // Update Bagi Hasil and Nilai Voucher when Bagi Hasil Persen changes
    _bagiHasilController.addListener(
        _updateFieldsBasedOnBagiHasil); // Update Bagi Hasil Persen and Nilai Voucher when Bagi Hasil changes
    _nilaiVoucherController.addListener(
        _updateFieldsBasedOnNilaiVoucher); // Update Bagi Hasil and Bagi Hasil Persen when Nilai Voucher changes
    _nilaiVoucherController.addListener(_checkIfButtonShouldBeEnabled);
  }

  void _fetchStoreData() async {
    // Fetch the store data using the service
    final response =
        await serviceKasir.getTransaksiByToko(widget.idToko.toString());
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

  void _updateFieldsBasedOnBagiHasil() {
    if (_isUpdatingBagiHasil) return; // Prevent recursive calls
    _isUpdatingBagiHasil = true;

    String totalBelanjaText = _totalBelanjaController.text.replaceAll('.', '');
    double totalBelanja = double.tryParse(totalBelanjaText) ?? 0.0;
    final bagiHasil =
        double.tryParse(_bagiHasilController.text.replaceAll('.', '')) ?? 0.0;

    if (totalBelanja > 0 && bagiHasil > 0) {
      final bagiHasilPersen = (bagiHasil / totalBelanja) * 100;
      final nilaiVoucher = 2 * bagiHasil;

      _bagiHasilPersenanController.value = TextEditingValue(
        text: _formatNumberWithThousandsSeparator(bagiHasilPersen),
        selection: TextSelection.collapsed(
            offset:
                _formatNumberWithThousandsSeparator(bagiHasilPersen).length),
      );
      _nilaiVoucherController.value = TextEditingValue(
        text: _formatNumberWithThousandsSeparator(nilaiVoucher),
        selection: TextSelection.collapsed(
            offset: _formatNumberWithThousandsSeparator(nilaiVoucher).length),
      );
    } else {
      _bagiHasilPersenanController.clear();
      _nilaiVoucherController.clear();
    }

    _checkIfButtonShouldBeEnabled();
    _isUpdatingBagiHasil = false; // Reset the flag
  }

  void _updateFieldsBasedOnNilaiVoucher() {
    if (_isUpdatingNilaiVoucher) return; // Prevent recursive calls
    _isUpdatingNilaiVoucher = true;

    final nilaiVoucher =
        double.tryParse(_nilaiVoucherController.text.replaceAll('.', '')) ??
            0.0;
    final bagiHasil = nilaiVoucher / 2;

    if (bagiHasil > 0) {
      String totalBelanjaText =
          _totalBelanjaController.text.replaceAll('.', '');
      double totalBelanja = double.tryParse(totalBelanjaText) ?? 0.0;

      final bagiHasilPersen = (bagiHasil / totalBelanja) * 100;

      _bagiHasilController.value = TextEditingValue(
        text: _formatNumberWithThousandsSeparator(bagiHasil),
        selection: TextSelection.collapsed(
            offset: _formatNumberWithThousandsSeparator(bagiHasil).length),
      );
      _bagiHasilPersenanController.value = TextEditingValue(
        text: _formatNumberWithThousandsSeparator(bagiHasilPersen),
        selection: TextSelection.collapsed(
            offset:
                _formatNumberWithThousandsSeparator(bagiHasilPersen).length),
      );
    } else {
      _bagiHasilController.clear();
      _bagiHasilPersenanController.clear();
    }

    _checkIfButtonShouldBeEnabled();
    _isUpdatingNilaiVoucher = false; // Reset the flag
  }

  void _onInputChanged() {
  String totalBelanjaText =
      _totalBelanjaController.text.replaceAll('.', '').replaceAll(',', '.');
  double totalBelanja = double.tryParse(totalBelanjaText) ?? 0.0;
  double bagiHasilPersen = double.tryParse(
          _bagiHasilPersenanController.text.replaceAll(',', '.')) ??
      0.0;

  // Cek jika Bagi Hasil Persen melebihi 50, batasi menjadi 50
  if (bagiHasilPersen > 50) {
    setState(() {
      bagiHasilPersen = 50;
      _bagiHasilPersenanController.value = TextEditingValue(
        text: _formatNumberWithThousandsSeparator(bagiHasilPersen),
        selection: TextSelection.collapsed(
            offset: _formatNumberWithThousandsSeparator(bagiHasilPersen).length),
      );
    });
  }

  if (totalBelanja > 0) {
    // Format total belanja with thousands separators
    _totalBelanjaController.value = TextEditingValue(
      text: _formatNumberWithThousandsSeparator(totalBelanja),
      selection: TextSelection.collapsed(
          offset: _formatNumberWithThousandsSeparator(totalBelanja).length),
    );
  }

  // Calculate Bagi Hasil and Nilai Voucher based on Bagi Hasil Persen
  if (totalBelanja > 0 && bagiHasilPersen > 0) {
    final bagiHasil = totalBelanja * (bagiHasilPersen / 100);
    final nilaiVoucher = 2 * bagiHasil;

    // Format and update Bagi Hasil and Nilai Voucher
    _bagiHasilController.value = TextEditingValue(
      text: _formatNumberWithThousandsSeparator(bagiHasil),
      selection: TextSelection.collapsed(
          offset: _formatNumberWithThousandsSeparator(bagiHasil).length),
    );
    _nilaiVoucherController.value = TextEditingValue(
      text: _formatNumberWithThousandsSeparator(nilaiVoucher),
      selection: TextSelection.collapsed(
          offset: _formatNumberWithThousandsSeparator(nilaiVoucher).length),
    );
  } else {
    _bagiHasilController.clear();
    _nilaiVoucherController.clear();
  }

  _checkIfButtonShouldBeEnabled();
}



String _formatNumberWithThousandsSeparator(double number) {
  final format = NumberFormat("#,##0.##", "en_US"); // Pertahankan angka desimal tanpa membulatkan
  return format.format(number).replaceAll(',', '.'); // Replace commas with dots for Indonesian locale
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
          totalBelanja: double.tryParse(
                  _totalBelanjaController.text.replaceAll('.', '')) ??
              0.0,
          bagiHasilPersenan:
              double.tryParse(_bagiHasilPersenanController.text) ?? 0.0,
          bagiHasil:
              double.tryParse(_bagiHasilController.text.replaceAll('.', '')) ??
                  0.0,
          nilaiVoucher: double.tryParse(
                  _nilaiVoucherController.text.replaceAll('.', '')) ??
              0.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.white, // Set background color of the page to white
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
                onPressed:
                    _isButtonEnabled ? _navigateToTinjauPesananInstan : null,
                style: TextButton.styleFrom(
                  backgroundColor: _isButtonEnabled
                      ? Color(0xFF005466)
                      : Color(0xFFD1D5DB), // Dynamic background color
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(
                  'Selanjutnya',
                  style: TextStyle(
                    color: _isButtonEnabled
                        ? Color(0xFFF8F8F8)
                        : Color(0xFF9CA3AF), // Dynamic text color
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
            hintStyle: TextStyle(
                color: const Color(0xFFD1D5DB)), // Mengubah warna hintText
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
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    RegExp(r'[0-9.,]')), // Mengizinkan angka, titik, dan koma
              ],
              decoration: InputDecoration(
                hintText: '27,5',
                hintStyle: TextStyle(color: const Color(0xFFD1D5DB)),
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
              keyboardType: TextInputType.numberWithOptions(decimal: true),
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
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    RegExp(r'[0-9.,]')), // Mengizinkan angka, titik, dan koma
              ],
              decoration: InputDecoration(
                hintText: '5.000',
                hintStyle: TextStyle(color: const Color(0xFFD1D5DB)),
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
              keyboardType: TextInputType.numberWithOptions(decimal: true),
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
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                  RegExp(r'[0-9,.]')), // Mengizinkan angka, titik, dan koma
            ],
            decoration: InputDecoration(
              hintText: '10.000',
              hintStyle: TextStyle(color: const Color(0xFFD1D5DB)),
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
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
        ),
      ],
    );
  }
}
