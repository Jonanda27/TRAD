import 'package:flutter/material.dart';
import 'package:trad/Screen/AuthScreen/Login/login_screen.dart';
import 'package:trad/Screen/AuthScreen/Register/register_screen.dart';
import 'package:trad/Screen/HomeScreen/home_screen.dart';
import 'package:trad/main.dart';
import 'package:trad/utility/text_opensans.dart';
import 'package:trad/utility/warna.dart';
import 'package:trad/widget/component/costume_button.dart'; // Import main.dart untuk akses ke HomeScreen

class HalamanAwal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/img/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/img/Logo2.png',
              height: 100,
            ),
            SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                children: [
          //         ElevatedButton(
          //           onPressed: () {
          //             // Lakukan navigasi ke HomeScreen setelah login berhasil
          //             Navigator.pushReplacement(
          //               context,
          //               MaterialPageRoute(builder: (context) => LoginScreen()),
          //             );
          //           },
          //           child: Text(
          //             'Masuk',
          //             style: TextStyle(fontSize: 18, color: MyColors.textWhite()),
          //           ),
          //           style: ElevatedButton.styleFrom(
          //             minimumSize: Size(double.infinity, 50),
          //             backgroundColor: MyColors.greenDarkButton(),
          //             shape: RoundedRectangleBorder(
          //               borderRadius: BorderRadius.circular(8.0), // Set corner radius here
          //             ),
          //             side: BorderSide(
          //   width: 1,
          //   color: MyColors.greenDarkButton(),
          // ),
          //           ),
          //         ),

                  SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
                      // Lakukan navigasi ke HomeScreen setelah login berhasil
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
        child: OpenSansText.custom(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            warna: MyColors.textWhite(),
            text: "Masuk",),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6), // <-- Radius
          ),
          side: BorderSide(
            width: 1,
            color: MyColors.greenDarkButton(),
          ),
          backgroundColor: MyColors.greenDarkButton(),
      ),
    ),),
                  SizedBox(height: 20),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => RegisterScreen()),
                        );
                      },
                      child: Text(
                        'Registrasi',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        side: BorderSide(color: Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0), // Set corner radius here
                        ),
                      ),
                    ),
                  ),
  //                 CostumeButton(
  //   backgroundColorbtn: MyColors.Transparent(),
  //   backgroundTextbtn: MyColors.textWhite(),
  //   onTap: () {
  //                     Navigator.pushReplacement(
  //                       context,
  //                       MaterialPageRoute(builder: (context) => RegisterScreen()),
  //                     );
  //                   },  // Remove the condition here
  //   buttonText: 'Registrasi',
  //   height: 50.0,
  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
