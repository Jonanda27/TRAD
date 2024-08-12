// import 'package:flutter/material.dart';
// import 'package:trad/screen/HomeScreen/home_screen.dart';
// import 'package:trad/list_produk.dart';

// class MyBottomNavigationBar extends StatelessWidget {
//   final int currentIndex;
//   final Function(int) onTap;

//   MyBottomNavigationBar({required this.currentIndex, required this.onTap});

//   void _handleTap(int index, BuildContext context) {
//     onTap(index);
//     switch (index) {
//       case 0:
//         Navigator.pushNamed(context,'/beranda'); // Gunakan Navigator.pushNamed untuk navigasi ke '/home'
//         break;
//       case 1:
//         break;
//       case 2:
//         Navigator.pushNamed(context,'/beranda'); 
//         break;
//       case 3:
//         Navigator.pushReplacementNamed(context, '/listproduk');
//         break;
//       case 4:
//         Navigator.pushReplacementNamed(context, '/profiletoko');
//         break;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       type: BottomNavigationBarType.fixed,
//       backgroundColor:
//           const Color.fromRGBO(0, 84, 102, 1), // Ubah warna latar belakang di sini
//       currentIndex: currentIndex,
//       onTap: (index) => _handleTap(index, context),
//       items: const [
//         BottomNavigationBarItem(
//           icon:
//               Icon(Icons.home, color: Color.fromARGB(255, 255, 255, 255)),
//           label: '',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.credit_card,
//               color: Color.fromARGB(255, 255, 255, 255)),
//           label: '',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.history,
//               color: Color.fromARGB(255, 255, 255, 255)),
//           label: '',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.inventory,
//               color: Color.fromARGB(255, 255, 254, 254)),
//           label: '',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.store,
//               color: Color.fromARGB(255, 255, 255, 255)),
//           label: '',
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:trad/screen/HomeScreen/home_screen.dart';
import 'package:trad/list_produk.dart';
// import 'package:trad/Screen/HomeScreen/home_screen.dart';
import 'package:trad/store_profile.dart';

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
        // Tambahkan fungsi jika diperlukan
        break;
      case 2:
        _navigateToBeranda(context);
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
      MaterialPageRoute(builder: (context) => ProfileStore()),
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

