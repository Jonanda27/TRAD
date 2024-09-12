import 'package:flutter/material.dart';
import 'bayar_screen.dart'; // Import the BayarScreen

class BerhasilBayarPage extends StatelessWidget {
  final double jumlahTunai;
  final int userId; // Add userId to pass to BayarScreen

  BerhasilBayarPage({required this.jumlahTunai, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Pembayaran Voucher Berhasil!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF005466),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 80,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Mohon segera lengkapi pembayaran tunai sebesar Rp. ${jumlahTunai.toStringAsFixed(1)} pada Merchant',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Divider(color: Colors.grey), // Divider above the button
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BayarScreen(userId: userId), // Navigate to BayarScreen
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF005466),
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: Text('Oke'),
            ),
          ],
        ),
      ),
    );
  }
}
