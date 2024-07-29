import 'package:flutter/material.dart';
import 'package:trad/Utility/text_opensans.dart';
import 'package:trad/Utility/warna.dart';

class CostumeTextFormFieldWithoutBorderPrefix extends StatelessWidget {
  final TextEditingController textformController;
  final Widget icon;
  final String? errorText;
  final Color fillColors;
  final Color? iconSuffixColor;
  final String? hintText;
  final bool obscureText;
  const CostumeTextFormFieldWithoutBorderPrefix({
    super.key,
    required this.textformController,
    required this.icon,
    this.errorText,
    this.hintText,
    required this.fillColors,
    this.iconSuffixColor,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    //Tinggi full HP
    //Lebar  full HP

    return Column(
      children: [
        TextFormField(
          cursorColor: MyColors.iconGrey(),
          textAlign: TextAlign.start,
          controller: textformController,
          obscureText: obscureText,
          decoration: InputDecoration(
            filled: true,
            fillColor: fillColors,
            hintText: hintText,
            errorText: errorText,
            suffixIconColor: iconSuffixColor,
            suffixIcon: icon,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
          ),
        ),
      ],
    );
  }
}
