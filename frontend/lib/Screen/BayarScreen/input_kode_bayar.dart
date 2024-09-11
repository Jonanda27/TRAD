import 'package:flutter/material.dart';
import 'package:trad/Screen/BayarScreen/user_bayar_screen.dart';
import '../../Model/RestAPI/service_bayar.dart';

class InputKodeBayarScreen extends StatefulWidget {
  final int userId; // User ID should be passed to this screen

  InputKodeBayarScreen({required this.userId});

  @override
  _InputKodeBayarScreenState createState() => _InputKodeBayarScreenState();
}

class _InputKodeBayarScreenState extends State<InputKodeBayarScreen> {
  final TextEditingController _kodePembayaranController = TextEditingController();
  final ApiService _apiService = ApiService(); // Initialize ApiService
  bool _isLoading = false; // To manage loading state

  void _searchPaymentCode() async {
  String noNota = _kodePembayaranController.text;

  if (noNota.isEmpty) {
    _showMessage('Kode Pembayaran tidak boleh kosong');
    return;
  }

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
    // Navigate to UserBayarScreen with the necessary details
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserBayarScreen(
          noNota: noNota,
          idPembeli: widget.userId,
        ),
      ),
    );
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kode Pembayaran',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _kodePembayaranController,
                    decoration: InputDecoration(
                      hintText: 'Masukkan Kode Pembayaran',
                      prefixIcon: Icon(Icons.info_outline, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _searchPaymentCode, // Disable button while loading
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isLoading ? Colors.grey : Color(0xFF005466),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
    );
  }
}
