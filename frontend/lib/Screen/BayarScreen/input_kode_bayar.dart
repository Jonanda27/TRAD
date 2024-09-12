import 'package:flutter/material.dart';
import 'package:trad/Screen/BayarScreen/user_bayar_list_screen.dart';
import 'package:trad/Screen/BayarScreen/user_bayar_instan_screen.dart'; // Import UserBayarInstanScreen
import '../../Model/RestAPI/service_bayar.dart';

class InputKodeBayarScreen extends StatefulWidget {
  final int userId; // User ID should be passed to this screen

  InputKodeBayarScreen({required this.userId});

  @override
  _InputKodeBayarScreenState createState() => _InputKodeBayarScreenState();
}

class _InputKodeBayarScreenState extends State<InputKodeBayarScreen> {
  final TextEditingController _kodePembayaranController =
      TextEditingController();
  final ApiService _apiService = ApiService(); // Initialize ApiService
  final _formKey = GlobalKey<FormState>(); // Form key for validation
  bool _isLoading = false; // To manage loading state
  String? _validationMessage; // To store validation message

  void _searchPaymentCode() async {
    // Check if the form is valid
    if (!_formKey.currentState!.validate()) {
      return;
    }

    String noNota = _kodePembayaranController.text;

    setState(() {
      _isLoading = true;
    });

    final response = await _apiService.transaksiBayar(noNota, widget.userId);

    setState(() {
      _isLoading = false;
    });

    if (response.containsKey('error')) {
      _showMessage(response['error']);
    } else {
      // Check the 'jenisTransaksi' type in the response
      String jenisTransaksi = response['jenisTransaksi'] ?? '';

      if (jenisTransaksi == 'list_produk_toko') {
        // Navigate to UserBayarScreen for 'list_produk_toko'
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserBayarScreen(
              noNota: noNota,
              idPembeli: widget.userId,
            ),
          ),
        );
      } else if (jenisTransaksi == 'bayar_instan') {
        // Navigate to UserBayarInstanScreen for 'bayar_instan'
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserBayarInstanScreen(
              noNota: noNota,
              idPembeli: widget.userId,
            ),
          ),
        );
      } else {
        _showMessage('Jenis transaksi tidak dikenali');
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Custom AppBar
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF005466),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.0),
                    topRight: Radius.circular(12.0),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          'Kode Pembayaran',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Aligns children to the left
                  children: [
                    Text(
                      'Minta Merchant untuk menunjukan Kode Pembayaran di nota',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF005466),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Image.asset(
                      '/img/bayar.png', // Ensure this path is correct
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF005466),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Input Kode Bayar',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.white),
            onPressed: _showInfoDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Assign form key to the form
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Kode Pembayaran',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(width: 4), // Adjust space between text and icon
                  IconButton(
                    icon: Icon(Icons.info_outline, color: Colors.grey),
                    onPressed:
                        _showInfoDialog, // Show dialog when icon is pressed
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _kodePembayaranController,
                      decoration: InputDecoration(
                        hintText: 'Masukkan Kode Pembayaran',
                        hintStyle: TextStyle(
                            color: Color(0xFFD1D5DB)), // Set hint text color
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Kode Pembayaran tidak boleh kosong';
                        } 
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : _searchPaymentCode, // Disable button while loading
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isLoading ? Colors.grey : Color(0xFF005466),
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            'Cari',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
