import 'package:flutter/material.dart';
import 'package:trad/Utility/text_opensans.dart';

class CostumeButton extends StatelessWidget {
  final String? buttonText;
  final Color backgroundColorbtn, backgroundTextbtn;
  final Function()? onTap;
  final double height;
  final Color inactiveBackgroundColor;

  const CostumeButton({
    super.key,
    this.buttonText,
    required this.backgroundColorbtn,
    required this.onTap,
    required this.backgroundTextbtn,
    this.height = 50.0,
    this.inactiveBackgroundColor = Colors.grey, // Default to grey
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
          backgroundColor:
              onTap == null ? inactiveBackgroundColor : backgroundColorbtn,
        ),
      ),
    );
  }
}
