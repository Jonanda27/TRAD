import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trad/Screen/AuthScreen/Login/login_screen.dart';
import 'package:trad/Screen/AuthScreen/Register/register_screen.dart';
import 'package:trad/Utility/warna.dart';
import 'package:trad/Widget/component/costume_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //Tinggi full HP
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    //Lebar  full HP
    final mediaQueryWeight = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/img/background.png',
            fit: BoxFit.cover,
            height: mediaQueryHeight,
            width: mediaQueryWeight,
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 50),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 160,
                    child: SvgPicture.asset("assets/svg/Logo Primary.svg"),
                  ),
                  Padding(padding: EdgeInsets.only(top: 10, bottom: 60)),
                  CostumeButton(
                    backgroundColorbtn: MyColors.iconGrey(),
                    backgroundTextbtn: MyColors.textBlack(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                      );
                    },
                    buttonText: 'Masuk',
                  ),
                  Padding(padding: EdgeInsets.only(top: 10)),
                  Opacity(
                    opacity: 0.7,
                    child: CostumeButton(
                      backgroundColorbtn: Colors.transparent,
                      backgroundTextbtn: MyColors.textWhite(),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegisterScreen()),
                        );
                      },
                      buttonText: 'Register',
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
