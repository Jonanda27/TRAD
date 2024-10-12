import 'package:flutter/material.dart';
import 'package:trad/Utility/text_opensans.dart';
import 'package:trad/utility/warna.dart';

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
      child: OutlinedButton(
                      onPressed: 
         onTap,
                      child: Text(
                        buttonText.toString(),
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: onTap != Colors.white ?  Colors.white : MyColors.greenDarkButton()),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        side: BorderSide(color: onTap != Colors.white ?  Colors.white : MyColors.greenDarkButton()),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0), // Set corner radius here
                        ),
                      ),
                    ),
    );
  }
}
