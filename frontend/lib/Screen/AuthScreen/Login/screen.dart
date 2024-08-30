import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: AccountTypeScreen(),
    );
  }
}

class AccountTypeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get the dimensions of the screen
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final mediaQueryWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Image.asset(
            'assets/img/background.png', // The provided background asset
            fit: BoxFit.cover,
            height: mediaQueryHeight,
            width: mediaQueryWidth,
          ),
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Text(
                    'Pilih tipe akun',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Merchant Button
                AccountTypeButton(
                  icon: Icons.store,
                  title: 'Merchant',
                  subtitle: 'Masuk disini untuk mengelola toko',
                  onTap: () {
                    // Handle Merchant button tap
                  },
                ),
                SizedBox(height: 20),
                // Customer Button
                AccountTypeButton(
                  icon: Icons.person,
                  title: 'Customer',
                  subtitle: 'Masuk disini untuk belanja',
                  onTap: () {
                    // Handle Customer button tap
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AccountTypeButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const AccountTypeButton({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        margin: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 40,
              color: Color(0xFF00617F),
            ),
            SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00617F),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
