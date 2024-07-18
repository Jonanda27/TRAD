import 'package:flutter/material.dart';
import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:trad/Screen/WelcomeScreen/welcome_screen.dart';
import 'package:trad/Utility/warna.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FlutterSplashScreen.scale(
      backgroundImage: Image.asset("assets/img/background.png"),
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          MyColors.primaryHover(),
          MyColors.primary(),
        ],
      ),
      childWidget: SizedBox(
        height: 160,
        child: SvgPicture.asset("assets/svg/Logo Primary.svg"),
      ),
      duration: const Duration(milliseconds: 1500),
      animationDuration: const Duration(milliseconds: 1000),
      onAnimationEnd: () => debugPrint("On Scale End"),
      nextScreen: const WelcomeScreen(),
    );
  }
}
