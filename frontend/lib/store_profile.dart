import 'package:flutter/material.dart';
import 'bottom_navigation_bar.dart';
import 'store_edit.dart';

class ProfileStore extends StatefulWidget {
  @override
  _ProfileStoreState createState() => _ProfileStoreState();
}

class _ProfileStoreState extends State<ProfileStore> {
  bool isOpen = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(36, 75, 89, 1),
        title: Text('Profile Toko', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              // Share action
            },
            color: Colors.white,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              margin: EdgeInsets.all(4.0),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          color: Colors.grey[300],
                          margin: EdgeInsets.only(right: 12.0),
                        ),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Smoke.In Bandung',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Jalan Papanggungan no. 32, Kec. KiaracondongBandung, Jawa Barat',
                                style: TextStyle(color: Colors.grey[600]),
                                softWrap: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.0),
                    Text('085723044442', style: TextStyle(fontSize: 14.0)),
                    SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Jam Operasional',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Senin - Jumat'),
                            Text('10 AM - 5 PM'),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.yellow[500]),
                                Text(' 5.0'),
                              ],
                            ),
                            Text('5RB Disukai'),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Saldo Poin Toko',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('123,456,789'),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Rentang Voucher',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('30% - 100%'),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Jumlah Produk',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('3'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.edit, color: Colors.white),
                      label: Text('Edit Informasi Toko',
                          style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => EditStoreScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(36, 75, 89, 1),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Row(
                    children: [
                      Text('Buka',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Switch(
                        value: isOpen,
                        onChanged: (value) {
                          setState(() {
                            isOpen = value;
                          });
                        },
                        activeColor: const Color.fromRGBO(36, 75, 89, 1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            buildSection('Akun Toko', [
              'Ganti Toko',
              'Ulasan Pembeli Keseluruhan',
              'Pencairan Poin Toko',
              'Hapus Toko',
            ]),
            buildSection('Akun Ku, Layanan Poin, dan Lainnya', [
              'Profile Akun Ku',
              'Akun Bank',
              'Jual Subscription TRAD',
            ]),
            buildSection('Bantuan', [
              'Bantuan TRAD Care',
              'Beri Ulasan kepada TRAD',
            ]),
          ],
        ),
      ),
      // bottomNavigationBar: MyBottomNavigationBar(
      //   currentIndex: 0, // Ganti dengan index yang sesuai
      //   onTap: (index) {
      //     // Lakukan navigasi atau aksi sesuai dengan index yang dipilih
      //   },
      // ),
    );
  }

  Widget buildSection(String title, List<String> items) {
    return Card(
      margin: EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ...items.map((item) {
            return ListTile(
              title: Text(item),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                // Handle item tap
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget buildBottomNavigationItem(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon),
        Text(label, style: TextStyle(fontSize: 12.0)),
      ],
    );
  }
}
