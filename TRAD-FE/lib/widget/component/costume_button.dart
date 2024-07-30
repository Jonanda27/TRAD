import 'package:flutter/material.dart';
import 'package:trad/Utility/text_opensans.dart';

class CostumeButton extends StatelessWidget {
  final String? buttonText;
  final Color backgroundColorbtn, backgroundTextbtn;
  final Function()? onTap;

  const CostumeButton({
    super.key,
    this.buttonText,
    required this.backgroundColorbtn,
    required this.onTap,
    required this.backgroundTextbtn,
  });

  @override
  Widget build(BuildContext context) {
    //Lebar  full HP
    final mediaQueryWeight = MediaQuery.of(context).size.width;
    return SizedBox(
      width: mediaQueryWeight,
      child: ElevatedButton(
        onPressed: onTap,
        child: OpenSansText.custom(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            warna: backgroundTextbtn,
            text: buttonText.toString()),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6), // <-- Radius
          ),
          side: BorderSide(
            width: 1,
            color: backgroundTextbtn,
          ),
          backgroundColor: backgroundColorbtn,
        ),
      ),
    );
  }
}
