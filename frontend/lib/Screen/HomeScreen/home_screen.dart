import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trad/bottom_navigation_bar.dart';
import 'package:trad/produk_list.dart';
import 'package:trad/store_add.dart';
import 'package:trad/store_list.dart';

class HomeScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  HomeScreen({super.key});

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/img/bg3.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    color: Colors.teal[700]?.withOpacity(0),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey[300],
                          child:
                              const Icon(Icons.person, size: 40, color: Colors.white),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Guest 1',
                          style: TextStyle(
                            color: Color.fromRGBO(0, 84, 102, 1),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 16.0),
                                          child: Row(
                                            children: [
                                              Icon(Icons.star,
                                                  size: 30,
                                                  color: Color.fromRGBO(
                                                      0, 84, 102, 1)),
                                              SizedBox(width: 10),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'TRAD Poin',
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
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(right: 60.0),
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
                                              const Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Toko',
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
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 16.0),
                                          child: Row(
                                            children: [
                                              Icon(Icons.card_giftcard,
                                                  size: 30,
                                                  color: Color.fromRGBO(
                                                      0, 84, 102, 1)),
                                              SizedBox(width: 10),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Voucher Toko',
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
                                      ),
                                      Expanded(
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
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ActionButton(
                              'Tambah Toko',
                              Icons.add_business,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AddStoreForm()),
                                );
                              },
                            ),
                            ActionButton(
                              'Pembukaan Toko',
                              Icons.support_agent,
                              onPressed: () {
                              },
                            ),
                            ActionButton(
                              'TRAD Care',
                              Icons.support,
                              onPressed: () {
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    color: const Color.fromRGBO(0, 84, 102, 1).withOpacity(1),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      builder: (context) => StoreListPage()),
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
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 45,
                      horizontal: constraints.maxWidth * 0.05,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProductListing()),
                              );
                            },
                            child: Column(
                              children: [
                                Image.asset(
                                  'assets/img/image.png',
                                  height: constraints.maxWidth * 0.2,
                                  width: constraints.maxWidth * 0.2,
                                ),
                                const SizedBox(height: 5),
                                const Text('Smoke.In Bandung',
                                    textAlign: TextAlign.center),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProductListing()),
                              );
                            },
                            child: Column(
                              children: [
                                Image.asset(
                                  'assets/img/image.png',
                                  height: constraints.maxWidth * 0.2,
                                  width: constraints.maxWidth * 0.2,
                                ),
                                const SizedBox(height: 5),
                                const Text('Smoke.In Bandung',
                                    textAlign: TextAlign.center),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProductListing()),
                              );
                            },
                            child: Column(
                              children: [
                                Image.asset(
                                  'assets/img/image.png',
                                  height: constraints.maxWidth * 0.2,
                                  width: constraints.maxWidth * 0.2,
                                ),
                                const SizedBox(height: 5),
                                const Text('Smoke.In Bandung',
                                    textAlign: TextAlign.center),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: MyBottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          // Lakukan navigasi atau aksi sesuai dengan index yang dipilih
        },
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, String title, String route,
      {bool isLogout = false}) {
    return ListTile(
      title: Text(title),
      onTap: () {
        if (isLogout) {
          // Handle logout logic
        } else {
          Navigator.pushNamed(context, route);
        }
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      color: const Color.fromRGBO(219, 231, 228, 1),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color.fromRGBO(97, 97, 97, 1),
        ),
      ),
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
              child:
                  Icon(icon, color: const Color.fromRGBO(0, 84, 102, 1), size: 40.0),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
