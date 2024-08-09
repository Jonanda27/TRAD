import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trad/Screen/AuthScreen/Login/login_screen.dart';
import 'package:trad/Utility/icon.dart';
import 'package:trad/Utility/text_opensans.dart';
import 'package:trad/Utility/warna.dart';
import 'package:trad/Widget/component/costume_button.dart';

class SuccessRegistrasi extends StatefulWidget {
  const SuccessRegistrasi({super.key});

  @override
  State<SuccessRegistrasi> createState() => _SuccessRegistrasiState();
}

class _SuccessRegistrasiState extends State<SuccessRegistrasi> {
  bool _visible = true;
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
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: AnimatedOpacity(
                  opacity: _visible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 49,
                        width: 60,
                        child: SvgPicture.asset("assets/svg/Logo Icon.svg"),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      OpenSansText.custom(
                          text: 'Registrasi Akun',
                          fontSize: 24,
                          warna: MyColors.textWhite(),
                          fontWeight: FontWeight.w700),
                      OpenSansText.custom(
                          text: 'Berhasil',
                          fontSize: 24,
                          warna: MyColors.textWhite(),
                          fontWeight: FontWeight.w700),
                      const SizedBox(
                        height: 32,
                      ),
                      MyIcon.iconSuccess(size: 60),
                      const SizedBox(
                        height: 23,
                      ),
                      OpenSansText.custom(
                          text:
                              'Registrasi akun berhasil ! Tekan selesai untuk segera masuk menggunakan akun baru Anda',
                          fontSize: 12,
                          warna: MyColors.textWhite(),
                          fontWeight: FontWeight.w400),
                      const SizedBox(
                        height: 25,
                      ),
                      CostumeButton(
                        buttonText: "Selesai",
                        backgroundColorbtn: MyColors.iconGrey(),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen()),
                          );
                        },
                        backgroundTextbtn: MyColors.black(),
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
