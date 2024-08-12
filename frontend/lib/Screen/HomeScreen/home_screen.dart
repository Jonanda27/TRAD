import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trad/Model/RestAPI/service_home.dart'; // Pastikan ini mengimpor kelas yang benar
import 'package:trad/bottom_navigation_bar.dart';
import 'package:trad/store_list.dart';
import 'package:trad/tambah_produk.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Future<Map<String, dynamic>> homeData;
  int? userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('id'); // Simpan userId dari SharedPreferences

    if (userId != null) {
      setState(() {
        homeData = HomeService().fetchHomeData(
            userId!); // Mengambil data dengan ID pengguna yang diambil dari SharedPreferences
      });
    } else {
      // Tangani kasus di mana ID pengguna tidak ditemukan
      print('ID pengguna tidak ditemukan');
    }
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      key: _scaffoldKey,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(0, 84, 102, 1),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/svg/icons/icons-setting.svg',
            height: 24.0,
            width: 24.0,
          ),
          onPressed: _openDrawer,
        ),
        title: Image.asset(
          'assets/img/logo.png',
          height: 75,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
              color: const Color.fromRGBO(0, 84, 102, 1),
              child: const Text(
                'Pengaturan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            _buildSectionHeader('Akun'),
            _buildDrawerItem(context, 'Profil Saya', '/profile'),
            const Divider(),
            _buildDrawerItem(context, 'Ubah Rekening Bank', '/editbank'),
            const Divider(),
            _buildDrawerItem(context, 'Ubah Sandi', '/ubahsandi'),
            const Divider(),
            _buildDrawerItem(context, 'Ubah PIN', '/ubahpin'),
            _buildSectionHeader('Pengaturan Aplikasi'),
            _buildDrawerItem(context, 'Notifikasi', '/notifikasi'),
            _buildSectionHeader('Bantuan'),
            _buildDrawerItem(context, 'Pusat Bantuan TRAD Care', '/tradcare'),
            const Divider(),
            _buildDrawerItem(context, 'Tips dan Trik', '/tipsdantrik'),
            const Divider(),
            _buildDrawerItem(context, 'Kebijakan TRAD', '/kebijakantrad'),
            const Divider(),
            _buildDrawerItem(context, 'Nilai Kami', '/nilaikami'),
            const Divider(),
            _buildDrawerItem(context, 'Informasi', '/informasi'),
            const Divider(),
            _buildDrawerItem(context, 'Hapus Akun', '/hapusakun'),
            const Divider(),
            _buildDrawerItem(context, 'Log Out', '/logout', isLogout: true),
          ],
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: homeData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Gagal memuat data'));
          } else {
            final data = snapshot.data!;
            return SingleChildScrollView(
              child: Container(
                width: double.infinity,
                height: screenHeight,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/img/bg3.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      color: Colors.teal[700]?.withOpacity(0),
                      // padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: data['fotoProfil'] != null &&
                                    data['fotoProfil'].isNotEmpty
                                ? NetworkImage(data['fotoProfil'])
                                    as ImageProvider
                                : const AssetImage(
                                        'assets/img/default_profile.jpg')
                                    as ImageProvider,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            data['nama'],
                            style: const TextStyle(
                              color: Color.fromRGBO(0, 84, 102, 1),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 16.0),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.star,
                                                size: 30,
                                                color: Color.fromRGBO(
                                                    0, 84, 102, 1)),
                                            const SizedBox(width: 10),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'TRAD Poin',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey),
                                                ),
                                                Text(
                                                  data['tradPoint'].toString(),
                                                  style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            right:
                                                57.2), // Adjust the padding value here
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            SvgPicture.asset(
                                              'assets/svg/icons/icons-shope.svg',
                                              height: 30,
                                              width: 30,
                                              fit: BoxFit.scaleDown,
                                            ),
                                            const SizedBox(width: 10),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Toko',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                Text(
                                                  data['jumlahToko'].toString(),
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 16.0),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.card_giftcard,
                                                size: 30,
                                                color: Color.fromRGBO(
                                                    0, 84, 102, 1)),
                                            const SizedBox(width: 10),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Voucher Toko',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey),
                                                ),
                                                Text(
                                                  data['tradVoucher']
                                                      .toString(),
                                                  style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Icon(Icons.account_balance_wallet,
                                              size: 30,
                                              color: Color.fromRGBO(
                                                  0, 84, 102, 1)),
                                          SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Saldo Poin Toko',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey),
                                              ),
                                              Text(
                                                '-',
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                // Add Action Buttons
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    ActionButton(
                                      'Tambah Toko',
                                      Icons.add_business,
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  HomeScreen()),
                                        );
                                      },
                                    ),
                                    ActionButton(
                                      'Pembukaan Toko',
                                      Icons.support_agent,
                                      onPressed: () {
                                        // Handle action
                                      },
                                    ),
                                    ActionButton(
                                      'TRAD Care',
                                      Icons.support,
                                      onPressed: () {
                                        // Handle action
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const TambahProdukScreen(),
                                        ),
                                      );
                                    },
                                    child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ))),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            color: const Color.fromRGBO(0, 84, 102, 1)
                                .withOpacity(1),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Toko Saya',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  StoreListPage()),
                                        );
                                      },
                                      child: const Text(
                                        'Lihat Semua',
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          buildStoreItem(
                            'assets/img/default_profile.jpg', // Replace with your actual image path
                            'Smoke.In',
                            'Bandung',
                            true, // This is to determine if the image is colored or not
                          ),
                          buildStoreItem(
                            'assets/img/default_profile.jpg', // Replace with your actual image path
                            'Lemur Resto',
                            'Jakarta',
                            false,
                          ),
                          buildStoreItem(
                            'assets/img/default_profile.jpg', // Replace with your actual image path
                            'Lemur Resto',
                            'Bandung',
                            false,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
      bottomNavigationBar: MyBottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          // Lakukan navigasi atau aksi sesuai dengan index yang dipilih
        },
        userId: userId ?? 0,
      ),
    );
  }

  Widget buildStoreItem(String imagePath, String name, String location, bool isHighlighted) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: isHighlighted ? Colors.black : Colors.grey[200],
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Image.asset(
            imagePath,
            width: 64.0,
            height: 64.0,
          ),
        ),
        SizedBox(height: 8.0),
        Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isHighlighted ? Colors.black : Colors.grey,
          ),
        ),
        Text(
          location,
          style: TextStyle(
            color: isHighlighted ? Colors.black : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, String title, String route,
      {bool isLogout = false}) {
    return ListTile(
      title: Text(title),
      onTap: () {
        if (isLogout) {
          // Tambahkan logika untuk logout jika perlu
          Navigator.popUntil(context, (route) => route.isFirst);
        } else {
          Navigator.pushNamed(context, route);
        }
      },
    );
  }
}

class ActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onPressed;

  ActionButton(this.title, this.icon, {required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(219, 231, 228, 1),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 12, color: Color.fromRGBO(172, 176, 181, 1))),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(icon,
                  color: const Color.fromRGBO(0, 84, 102, 1), size: 40.0),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
