import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trad/Provider/profile_provider.dart';
import 'package:trad/Provider/provider_auth.dart';
import 'package:trad/Screen/AuthScreen/Register/register_screen.dart';
import 'package:trad/Screen/HomeScreen/home_screen.dart';
import 'package:trad/list_produk.dart';
import 'package:trad/login.dart';
import 'package:trad/profile.dart';
import 'package:trad/produk_list.dart';
import 'package:trad/edit_bank.dart';
import 'package:trad/ubah_sandi.dart';
import 'package:trad/ubah_pin.dart';
import 'package:trad/store_profile.dart';
import 'package:trad/tambah_produk.dart';


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
      onGenerateRoute: (settings) {
        // Handle named routes
        if (settings.name == '/tambahproduk') {
          final idToko = settings.arguments as int; // Cast arguments to the expected type
          return MaterialPageRoute(
            builder: (context) {
              return TambahProdukScreen(idToko: idToko);
            },
          );
        }

        // Define other routes here...
        switch (settings.name) {
          case '/home':
            return MaterialPageRoute(builder: (context) => HalamanAwal());
          case '/profile':
            return MaterialPageRoute(builder: (context) => ProfileScreen());
          // case '/editbank':
          //   // return MaterialPageRoute(builder: (context) => const EditRekeningBankPage());
          case '/ubahsandi':
            return MaterialPageRoute(builder: (context) => UbahSandiPage());
          case '/beranda':
            return MaterialPageRoute(builder: (context) => HomeScreen());
          case '/ubahpin':
            return MaterialPageRoute(builder: (context) => UbahPinPage());
          case '/profiletoko':
            return MaterialPageRoute(builder: (context) => ProfileStore());
          case '/register':
            return MaterialPageRoute(builder: (context) => const RegisterScreen());
          default:
            return null;
        }
      },
    );
  }
}
