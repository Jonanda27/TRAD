import 'package:flutter/material.dart';
import 'package:trad/screen/HomeScreen/home_screen.dart';

class MyBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  MyBottomNavigationBar({required this.currentIndex, required this.onTap});

  void _handleTap(int index, BuildContext context) {
    onTap(index);
    switch (index) {
      case 0:
        Navigator.pushNamed(context,'/home'); // Gunakan Navigator.pushNamed untuk navigasi ke '/home'
        break;
      case 1:
        break;
      case 2:
         Navigator.pushNamed(context,'/home'); 
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/listproduk');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profiletoko');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor:
          const Color.fromRGBO(0, 84, 102, 1), // Ubah warna latar belakang di sini
      currentIndex: currentIndex,
      onTap: (index) => _handleTap(index, context),
      items: const [
        BottomNavigationBarItem(
          icon:
              Icon(Icons.home, color: Color.fromARGB(255, 255, 255, 255)),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.credit_card,
              color: Color.fromARGB(255, 255, 255, 255)),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history,
              color: Color.fromARGB(255, 255, 255, 255)),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory,
              color: Color.fromARGB(255, 255, 254, 254)),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.store,
              color: Color.fromARGB(255, 255, 255, 255)),
          label: '',
        ),
      ],
    );
  }
}
