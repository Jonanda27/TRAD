import 'package:flutter/material.dart';
import 'package:trad/Screen/KasirScreen/kasir_screen.dart';
import 'package:trad/Screen/KasirScreen/riwayat_transaksi.dart';
import 'package:trad/Screen/TokoScreen/list_toko.dart';
import 'package:trad/Screen/TokoScreen/profile_toko.dart';
import 'package:trad/screen/HomeScreen/home_screen.dart';
import 'package:trad/list_produk.dart';
// import 'package:trad/Screen/HomeScreen/home_screen.dart';

class MyBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final int userId;

  MyBottomNavigationBar({required this.currentIndex, required this.onTap,
    required this.userId, });

  void _handleTap(int index, BuildContext context) {
    onTap(index);
    switch (index) {
      case 0:
        _navigateToBeranda(context);
        break;
      case 1:
        _navigateToKasir(context);
        break;
      case 2:
        _navigateToRiwayat(context);
        break;
      case 3:
        _navigateToListProduk(context);
        break;
      case 4:
        _navigateToProfileToko(context);
        break;
    }
  }

  void _navigateToBeranda(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

    void _navigateToKasir(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) =>KasirScreen(idToko: userId)),
    );
  }

  void _navigateToRiwayat(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => RiwayatTransaksi(idToko: userId,)),
    );
  }

  void _navigateToListProduk(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ListProduk(id: userId)),
    );
  }

  void _navigateToProfileToko(BuildContext context) {
    // Ganti ProfileStore dengan widget profil toko Anda
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ProfileTokoScreen(tokoId:userId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color.fromRGBO(0, 84, 102, 1), // Ubah warna latar belakang
      currentIndex: currentIndex,
      onTap: (index) => _handleTap(index, context),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, color: Colors.white), // Ikon Home
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.credit_card, color: Colors.white), // Ikon Kartu Kredit
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history, color: Colors.white), // Ikon Riwayat
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory, color: Colors.white), // Ikon Inventaris
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.store, color: Colors.white), // Ikon Toko
          label: '',
        ),
      ],
    );
  }
}

