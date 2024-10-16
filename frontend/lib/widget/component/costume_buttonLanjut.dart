import 'package:flutter/material.dart';
import 'package:trad/Utility/text_opensans.dart';
import 'package:trad/Utility/warna.dart';

class CostumeButtonLanjut extends StatelessWidget {
  final String? buttonText;
  final Color backgroundColorbtn, backgroundTextbtn;
  final Function()? onTap;
  final double height;
  final Color inactiveBackgroundColor;

  const CostumeButtonLanjut({
    super.key,
    this.buttonText,
    required this.backgroundColorbtn,
    required this.onTap,
    required this.backgroundTextbtn,
    this.height = 50.0,
    this.inactiveBackgroundColor = const Color.fromARGB(255, 218, 221, 226), // Default to grey
  });

@override

Widget build(BuildContext context) {
  final mediaQueryWeight = MediaQuery.of(context).size.width;
  return SizedBox(
    width: mediaQueryWeight,
    height: height,
    child: ElevatedButton(
      onPressed: onTap,
      child: OpenSansText.custom(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          warna: onTap == null ? MyColors.textGrey() : backgroundTextbtn,
          text: buttonText.toString()),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        side: BorderSide(
          width: 1,
          color: onTap == null ? inactiveBackgroundColor : backgroundColorbtn,
        ),
        backgroundColor: onTap == null ? inactiveBackgroundColor.withOpacity(1.0) : backgroundColorbtn.withOpacity(1.0),
        disabledBackgroundColor: inactiveBackgroundColor.withOpacity(1.0),
      ),
    ),
  );
}
}
