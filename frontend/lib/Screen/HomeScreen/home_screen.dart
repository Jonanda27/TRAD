import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trad/Model/RestAPI/service_home.dart';
import 'package:trad/Model/RestAPI/service_toko.dart';
import 'package:trad/Model/toko_model.dart';
import 'package:trad/Screen/TokoScreen/list_toko.dart';
import 'package:trad/Screen/TokoScreen/tambah_toko.dart';
import 'package:trad/list_produk.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Future<Map<String, dynamic>> homeData = Future.value({});

  late Future<List<TokoModel>> storeData;
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
        homeData = HomeService().fetchHomeData(userId!); // Fetching home data
        storeData = TokoService().fetchStores();
      });
    } else {
      // Handle the case where the user ID is not found
      print('User ID not found');
    }
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  String formatNumber(String number) {
    try {
      // Menghapus '.00' jika ada di akhir string
      if (number.contains('.') && number.endsWith('00')) {
        number = number.split('.')[0];
      }

      // Mengonversi string menjadi integer
      final parsedNumber = int.parse(number.replaceAll('.', ''));

      // Menggunakan NumberFormat untuk format angka
      return NumberFormat.decimalPattern('id').format(parsedNumber);
    } catch (e) {
      print('Error parsing number: $e'); // Menangani error parsing
      return number; // Kembalikan string asli jika gagal
    }
  }

  ImageProvider<Object> _getProfileImage(String? fotoProfil) {
    if (fotoProfil != null && fotoProfil.isNotEmpty) {
      try {
        final decodedBytes = base64Decode(fotoProfil);
        return MemoryImage(decodedBytes);
      } catch (e) {
        print('Error decoding base64 image: $e');
        return const AssetImage('assets/img/default_profile.jpg');
      }
    } else {
      return const AssetImage('assets/img/default_profile.jpg');
    }
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
          icon: Icon(
            Icons.menu,
            size: 24.0,
            color: Colors.white,
          ),
          onPressed: _openDrawer,
        ),
        title: Image.asset('assets/img/logo.png', height: 54, width: 115),
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
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, // Align text and icon
                children: [
                  const Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close, // X icon
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the drawer
                    },
                  ),
                ],
              ),
            ),
            _buildSectionHeader('Akun'),
            _buildDrawerItem(context, 'Profil', '/profile'),
            const Divider(),
            _buildDrawerItem(context, 'Layanan Poin dan Lainnya', '/editbank'),
            _buildSectionHeader('Bantuan'),
            _buildDrawerItem(context, 'Pusat Bantuan TRAD Care', '/tradcare'),
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
                          GestureDetector(
                            onTap: () {
                              // Add logic to update profile picture here
                            },
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.grey[300],
                              backgroundImage:
                                  _getProfileImage(data['fotoProfil']),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            data['nama'] ?? 'Nama Tidak Tersedia',
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
                                            const EdgeInsets.only(left: 50.0),
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
                                                  formatNumber(data['tradPoint']
                                                      .toString()),
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
                                                85.0), // Adjust the padding value here
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
                                            const EdgeInsets.only(left: 50.0),
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
                                                  formatNumber(
                                                      data['tradVoucher']
                                                          .toString()),
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
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            right:
                                                25.0), // Adjust the padding value as needed
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Icon(
                                              Icons.account_balance_wallet,
                                              size: 30,
                                              color:
                                                  Color.fromRGBO(0, 84, 102, 1),
                                            ),
                                            SizedBox(width: 10),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Saldo Poin Toko',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                Text(
                                                  '-',
                                                  style: TextStyle(
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
                                                  TambahTokoScreen()),
                                        );
                                      },
                                    ),
                                    ActionButton(
                                      'Pembukaan Toko',
                                      Icons.support_agent,
                                      onPressed: () {
                                        // Handle action
                                      },
                                    ), // Jarak antara kartu kedua dan ketiga
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
                                              TambahTokoScreen(),
                                        ),
                                      );
                                    },
                                    child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(0),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ))),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(5),
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
                                                  ListTokoScreen()),
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
                          FutureBuilder<List<TokoModel>>(
                            future: storeData,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (snapshot.hasError) {
                                return const Center(
                                  child: Text('Gagal memuat data toko'),
                                );
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      top: 100.0), // Add top padding
                                  child: Center(
                                    child: Text(
                                      'Tidak ada toko yang tersedia',
                                      style: TextStyle(
                                        color: Colors
                                            .grey, // Change text color to grey
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                final stores = snapshot.data!;
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      top: 45.0), // Add top padding
                                  child: SizedBox(
                                    height:
                                        150.0, // Adjust height to fit the image aspect ratio
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: stores.length,
                                      itemBuilder: (context, index) {
                                        final store = stores[index];
                                        ImageProvider<Object>? imageProvider;
                                        if (store.fotoProfileToko != null &&
                                            store.fotoProfileToko!.isNotEmpty) {
                                          try {
                                            final decodedBytes = base64Decode(
                                                store.fotoProfileToko!);
                                            imageProvider =
                                                MemoryImage(decodedBytes);
                                          } catch (e) {
                                            print(
                                                'Error decoding base64 image: $e');
                                            imageProvider = AssetImage(
                                                'img/default_image.png'); // Use default image on error
                                          }
                                        } else {
                                          imageProvider = AssetImage(
                                              'img/default_image.png'); // Use default image when null or empty
                                        }
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ListProduk(
                                                    id: store
                                                        .id), // Kirimkan idToko ke ListProduk
                                              ),
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: Column(
                                              children: [
                                                Card(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.0),
                                                  ),
                                                  elevation: 5,
                                                  child: Container(
                                                    width:
                                                        100.0, // Set width to match the image size
                                                    height:
                                                        100.0, // Set height to match the image size
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15.0),
                                                      image: imageProvider !=
                                                              null
                                                          ? DecorationImage(
                                                              image:
                                                                  imageProvider,
                                                              fit: BoxFit.cover,
                                                            )
                                                          : null,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 8.0),
                                                Text(
                                                  store.namaToko,
                                                  style: TextStyle(
                                                    fontSize: 14.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              }
                            },
                          )
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
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      color: const Color(0xFFDBE7E4), // Background color set to DBE7E4
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, String title, String route,
      {bool isLogout = false}) {
    return ListTile(
      title: Text(title),
      trailing: Icon(
        Icons.chevron_right, // Icon > (chevron)
        color: Colors.grey, // You can change the color if needed
      ),
      onTap: () async {
        if (isLogout) {
          // Tambahkan logika untuk logout jika perlu
          Navigator.popUntil(context, (route) => route.isFirst);
        } else if (title == 'Pusat Bantuan TRAD Care') {
          final whatsappUrl = 'https://wa.me/+6285723304442';
          if (await canLaunch(whatsappUrl)) {
            await launch(whatsappUrl);
          } else {
            throw 'Could not launch $whatsappUrl';
          }
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
        width: 86, // Set width to 86
        height: 86, // Set height to 86
        decoration: BoxDecoration(
          color: const Color.fromRGBO(219, 231, 228, 1),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center, // Center content vertically
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10, // Set font size to 10
                  color: Color.fromRGBO(172, 176, 181, 1),
                ),
                textAlign: TextAlign.center, // Center text horizontally
              ),
              const SizedBox(height: 5), // Space between text and icon
              Icon(
                icon,
                color: const Color.fromRGBO(0, 84, 102, 1),
                size: 30.0, // Adjust the size if needed
              ),
            ],
          ),
        ),
      ),
    );
  }
}
