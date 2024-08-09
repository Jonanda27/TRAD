import 'package:flutter/material.dart';
import 'package:trad/main.dart';
import 'package:trad/profile.dart';

class PelayananPoin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(0, 84, 102, 1),
        title: Text(
          'Layanan Poin dan lainnya',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Guest 1',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildBonusCard(
                    icon: Icons.money,
                    label: 'Bonus Radar TRAD',
                    value: '-',
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _buildBonusCard(
                    icon: Icons.card_giftcard,
                    label: 'Bonus Radar TRAD',
                    value: '-',
                  ),
                ),
              ],
            ),
            SizedBox(height: 32),
            Text(
              'Akun Bank Terdaftar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildBankAccountInfo('Nama Bank', '-'),
            _buildBankAccountInfo('Nomor Rekening', '-'),
            _buildBankAccountInfo('Pemilik Rekening', '-'),
            SizedBox(height: 32),
            _buildLinkText('Ganti Akun Bank', () {
              // Handle change bank account
            }),
            SizedBox(height: 16),
            _buildLinkText('Pencairan Poin', () {
              // Handle points redemption
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBonusCard({required IconData icon, required String label, required String value}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Color.fromRGBO(0, 84, 102, 1)),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankAccountInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkText(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          color: Color.fromRGBO(0, 84, 102, 1),
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: PelayananPoin(),
  ));
}
