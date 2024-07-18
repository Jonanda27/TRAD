import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trad/Provider/provider_auth.dart';
import 'package:trad/Screen/AuthScreen/Register/register_screen.dart';
import 'package:trad/login.dart';
import 'package:trad/profile.dart';
import 'package:trad/produk_list.dart';
import 'package:trad/edit_bank.dart';
import 'package:trad/ubah_sandi.dart';
import 'package:trad/ubah_pin.dart';
import 'package:trad/store_profile.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RegisterProvider()),
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
        '/editbank': (context) => const EditRekeningBankPage(),
        '/ubahsandi': (context) => UbahSandiPage(),
        '/listproduk': (context) => ProductListing(),
        '/ubahpin': (context) => UbahPinPage(),
        '/profiletoko': (context) => ProfileStore(),
        '/register': (context) => const RegisterScreen(),
      },
    );
  }
}
