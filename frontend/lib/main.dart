import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trad/Provider/profile_provider.dart';
import 'package:trad/Provider/provider_auth.dart';
import 'package:trad/Screen/AuthScreen/Login/login.dart';
import 'package:trad/Screen/AuthScreen/Register/register_screen.dart';
import 'package:trad/Screen/HomeScreen/home_screen.dart';
import 'package:trad/Screen/KasirScreen/instan_kasir.dart';
import 'package:trad/Screen/ProfileScreen/ubah_pin.dart';
import 'package:trad/list_produk.dart';
import 'package:trad/Screen/ProfileScreen/profile.dart';
// import 'package:trad/produk_list.dart';
// import 'package:trad/Screen/ProfileScreen/edit_bank.dart';
import 'package:trad/Screen/ProfileScreen/ubah_sandi.dart';
// import 'package:trad/Screen/ProfileScreen/ubah_pin.dart';
import 'package:trad/tambah_produk.dart';
import 'package:intl/date_symbol_data_local.dart';
// import 'package:trad/login.dart';
// import 'package:trad/profile.dart';
// import 'package:trad/edit_bank.dart';
// import 'package:trad/ubah_sandi.dart';
// import 'package:trad/ubah_pin.dart';
import 'package:trad/tambah_produk.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trad/Model/RestAPI/service_api.dart';
import 'package:trad/Utility/warna.dart';
import 'package:trad/widgets/custom_loading_indicator.dart';

void main() {
  initializeDateFormatting('id_ID', null).then((_) {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => RegisterProvider()),  
          ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ],
        child: const MyApp(),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder<SharedPreferences>(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: CustomLoadingIndicator());
          } else if (snapshot.hasData) {
            final prefs = snapshot.data!;
            final token = prefs.getString('token');
            if (token != null) {
              return FutureBuilder<Map<String, dynamic>>(
                future: RestAPI().getCurrentUserData(),
                builder: (context, userDataSnapshot) {
                  if (userDataSnapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(body: CustomLoadingIndicator());
                  } else if (userDataSnapshot.hasData && userDataSnapshot.data!['success']) {
                    final userData = userDataSnapshot.data!['data'];
                    final role = userData['role'];
                    
                    prefs.setString('role', role);
                    prefs.setString('nama', userData['nama']);
                    prefs.setString('email', userData['email']);

                    if (role == 'Penjual') {
                      return HomeScreen();
                    } else {
                      return ProfileScreen();
                    }
                  } else {
                    prefs.clear();
                    return HalamanAwal();
                  }
                },
              );
            } else {
              return HalamanAwal();
            }
          } else {
            return HalamanAwal();
          }
        },
      ),
      onGenerateRoute: (settings) {
        if (settings.name == '/tambahproduk') {
          final idToko = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) {
              return TambahProdukScreen(idToko: idToko);
            },
          );
        }

        switch (settings.name) {
          case '/home':
            return MaterialPageRoute(builder: (context) => HalamanAwal());
          case '/profile':
            return MaterialPageRoute(builder: (context) => ProfileScreen());
          case '/ubahsandi':
            return MaterialPageRoute(builder: (context) => UbahSandiPage());
          case '/beranda':
            return MaterialPageRoute(builder: (context) => HomeScreen());
          case '/ubahpin':
            return MaterialPageRoute(builder: (context) => UbahPinPage());
          case '/register':
            return MaterialPageRoute(builder: (context) => const RegisterScreen());
          default:
            return null;
        }
      },
    );
  }
}