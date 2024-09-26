import 'package:flutter/material.dart';
import 'bayar_screen.dart'; // Import the BayarScreen

class BerhasilBayarPage extends StatelessWidget {
  final double jumlahTunai;
  final int userId; // Add userId to pass to BayarScreen

  // Make sure to parse or validate the values when passed
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
                  const Text(
                    'Pembayaran Voucher Berhasil!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF005466),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 80,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    // Ensure the jumlahTunai is formatted correctly as a number
                    'Mohon segera lengkapi pembayaran tunai sebesar Rp. ${jumlahTunai.toStringAsFixed(0)} pada Merchant',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.grey), // Divider above the button
            const SizedBox(height: 20),
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
                backgroundColor: const Color(0xFF005466),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('Oke'),
            ),
          ],
        ),
      ),
    );
  }
}
