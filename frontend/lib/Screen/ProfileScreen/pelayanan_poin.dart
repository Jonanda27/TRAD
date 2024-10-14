import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trad/Provider/provider_auth.dart';
import 'package:trad/Provider/profile_provider.dart';
import 'package:trad/Screen/AuthScreen/Login/login.dart';
import 'package:trad/Screen/AuthScreen/Register/register_screen.dart';
import 'package:trad/Screen/ProfileScreen/daftar_bank.dart';
import 'package:trad/Screen/ProfileScreen/edit_bank.dart';
import 'package:trad/Screen/ProfileScreen/profile.dart';
import 'package:trad/Screen/ProfileScreen/ubah_pin.dart';
import 'package:trad/produk_list.dart';
import 'package:trad/Screen/ProfileScreen/ubah_sandi.dart';
import 'package:trad/Model/RestAPI/service_bank.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RegisterProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HalamanAwal(),
      routes: {
        '/home': (context) => HalamanAwal(),
        '/profile': (context) => ProfileScreen(),
        // '/editbank': (context) => const EditRekeningBankPage(userId),
        '/ubahsandi': (context) => UbahSandiPage(),
        '/listproduk': (context) => ProductListing(),
        '/ubahpin': (context) => UbahPinPage(),
        '/register': (context) => const RegisterScreen(),
      },
    );
  }
}

class PelayananPoin extends StatefulWidget {
  @override
  _PelayananPoinState createState() => _PelayananPoinState();
}

class _PelayananPoinState extends State<PelayananPoin> {
  late BankService _bankService;
  late Future<bool> _userLoggedIn;
  Map<String, dynamic>? _layananPoinData;
  int? userId;

  @override
  void initState() {
    super.initState();
    _bankService = BankService(); // Initialize BankService
    _userLoggedIn = _isUserLoggedIn();
    _loadLayananPoinData();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('id'); // Simpan userId dari SharedPreferences
  }

  Future<bool> _isUserLoggedIn() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('id');
      return userId != null;
    } catch (e) {
      print('Error fetching user ID: $e');
      return false;
    }
  }

  Future<void> _loadLayananPoinData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('id');
      if (userId != null) {
        final layananPoinData = await _bankService.getLayananPoin(userId);
        setState(() {
          _layananPoinData = layananPoinData;
        });
      }
    } catch (e) {
      print('Error loading layanan poin data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(0, 84, 102, 1),
        title: Text(
          'Layanan Poin dan lainnya',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            color: Colors.white,
            size: 40,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<bool>(
        future: _userLoggedIn,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('Snapshot error: ${snapshot.error}');
            return Center(child: Text('Error loading user status.'));
          } else {
            bool isLoggedIn = snapshot.data ?? false;
            if (!isLoggedIn) {
              return Center(child: Text('Please log in to access this page.'));
            }
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: FutureBuilder<String?>(
                      future: _getUserName(), // Fetch username
                      builder: (context, snapshot) {
                        String userName =
                            _layananPoinData?['nama'] ?? 'macdeli';
                        return Text(
                          userName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildBonusCard('Bonus Radar TRAD',
                              '1.000.000.000', Icons.payment),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildBonusCard('Bonus Radar TRAD',
                              '1.000.000.000', Icons.wifi_tethering),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Akun Bank Terdaftar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildBankAccountInfo(
                      'Nama Bank', _layananPoinData?['namaBank'] ?? '-'),
                  _buildBankAccountInfo('Nomor Rekening',
                      _layananPoinData?['nomorRekening'] ?? '-'),
                  _buildBankAccountInfo('Pemilik Rekening',
                      _layananPoinData?['pemilikRekening'] ?? '-'),
                  SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildLinkText(
                      _layananPoinData?['namaBank'] == null
                          ? 'Daftar Akun Bank'
                          : 'Ganti Akun Bank',
                      () {
                        if (_layananPoinData?['namaBank'] == null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TambahRekeningBankPage(
                                    userId: userId ?? 0)),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    EditRekeningBankPage(userId: userId ?? 0)),
                          );
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildLinkText(
                      'Pencairan Poin',
                      () {
                        print('Pencairan Poin button pressed');
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Future<String?> _getUserName() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs
          .getString('userName'); // Fetch user name from SharedPreferences
    } catch (e) {
      print('Error fetching user name: $e');
      return null;
    }
  }

  Widget _buildBonusCard(String title, String amount, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(icon, color: Color.fromRGBO(0, 84, 102, 1), size: 20),
              SizedBox(width: 8),
              Expanded(
                // Add Expanded here to prevent overflow
                child: Text(
                  amount,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(0, 84, 102, 1),
                  ),
                  overflow:
                      TextOverflow.ellipsis, // Ellipsis to handle overflow text
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBankAccountInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment
            .start, // Memastikan agar judul dan data berada di atas
        children: [
          Expanded(
            flex: 2, // Mengatur lebar bagian label
            child: Text(
              label,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          SizedBox(width: 16), // Menambahkan jarak antara label dan data
          Expanded(
            flex: 3, // Mengatur lebar bagian value
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.left, // Rata kiri
              overflow:
                  TextOverflow.ellipsis, // Ellipsis untuk menangani overflow
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkText(String text, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Text(
        text,
        style: TextStyle(
          color: Color.fromRGBO(0, 84, 102, 1),
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
