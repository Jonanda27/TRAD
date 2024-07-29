import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trad/pelayanan_poin.dart';
import 'package:trad/edit_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isAutoSubscribeEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(0, 84, 102, 1),
        title: const Text('Profil Saya', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // Aksi ketika ikon notifikasi ditekan
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[300],
                  child: const Icon(Icons.person, size: 40, color: Colors.white),
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Guest 1',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Text('Subs : AKTIF'),
                        SizedBox(width: 16),
                        Text('Exp : dd/mm/yyyy'),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        SvgIcon('assets/svg/icons/icons-voucher.svg'),
                        SizedBox(width: 4),
                        Text('-'),
                        SizedBox(width: 16),
                        SvgIcon('assets/svg/icons/icons-point.svg'),
                        SizedBox(width: 4),
                        Text('-'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => EditProfilePage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(0, 84, 102, 1),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Edit Akun'),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text(
                'Radar TRAD',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(0, 84, 102, 1),
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Level Radar TRAD : -',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Aksi untuk Upgrade
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF005466), // Text color
                          side: const BorderSide(
                              color: Color(0xFF005466)), // Border color
                        ),
                        child: const Text('Upgrade'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16), // Adjusted spacing between sections
            ListTile(
              title: const Row(
                children: [
                  Text(
                    'Jumlah Referal',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SvgIcon(
                    'assets/svg/icons/icons-info.svg',
                    size: 16,
                  ),
                ],
              ),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text.rich(
                    TextSpan(
                      text: 'Target : ',
                      children: [
                        TextSpan(
                          text: '- / -',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.reply, size: 16, textDirection: TextDirection.rtl), // Ikon menghadap ke kanan
                      GestureDetector(
                        onTap: () {
                          // Aksi untuk Sebarkan Referal
                        },
                        child: const Text(
                          'Sebarkan Referal',
                          style: TextStyle(
                            color: Color(0xFF005466),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Text(
                  'Bonus Radar TRAD Bulan Ini',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(width: 4), // Adjust spacing as needed
                SvgIcon(
                  'assets/svg/icons/icons-info.svg',
                  size: 16,
                ),
              ],
            ),
            const TextField(
              decoration: InputDecoration(
                hintText: '0',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('max 1.000.000'),
                SizedBox(width: 8),
              ],
            ),
            const Divider(),
            ListTile(
              title: const Text(
                'Bayar Subscribe Radar TRAD',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                // Aksi untuk Bayar Subscribe
              },
            ),
            ListTile(
              title: const Text(
                'Gift Sub',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                // Aksi untuk Gift Sub
              },
            ),
            ListTile(
              title: const Text(
                'Auto Subscribe Radar',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: Switch(
                value: isAutoSubscribeEnabled,
                onChanged: (value) {
                  setState(() {
                    isAutoSubscribeEnabled = value;
                  });
                },
                activeColor: const Color.fromRGBO(0, 84, 102, 1),
              ),
            ),
            ListTile(
              title: const Text(
                'Layanan Poin dan lainnya',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => PelayananPoin()),
                );
              },
            ),
            ListTile(
              title: const Text(
                'Riwayat Transaksi',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                // Aksi untuk Riwayat Transaksi
              },
            ),
            const Divider(),
            ListTile(
              title: const Text(
                'Fitur Lainnya',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF005466),
                ),
              ),
              onTap: () {
                // Aksi untuk Fitur Lainnya
              },
            ),
            ListTile(
              title: const Text(
                'Profil Toko',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                // Aksi untuk Profil Toko
              },
            ),
            ListTile(
              title: const Text(
                'Log Out',
                style: TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                // Aksi untuk Log Out
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SvgIcon extends StatelessWidget {
  final String assetName;
  final double size;

  const SvgIcon(this.assetName, {Key? key, this.size = 24.0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetName,
      width: size,
      height: size,
    );
  }
}
