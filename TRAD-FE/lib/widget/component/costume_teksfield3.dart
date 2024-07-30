import 'package:flutter/material.dart';
import 'package:trad/Utility/text_opensans.dart';
import 'package:trad/Utility/warna.dart';

class CostumeTextFormFieldWithoutBorderPrefix2 extends StatelessWidget {
  final TextEditingController textformController;
  final Widget? icon;
  final String? errorText;
  final Color fillColors;
  final Color? iconSuffixColor;
  final String? hintText;
  final String? Function(String?)? validator; // Add this line

  const CostumeTextFormFieldWithoutBorderPrefix2({
    super.key,
    required this.textformController,
    this.icon,
    this.errorText,
    this.hintText,
    required this.fillColors,
    this.iconSuffixColor,
    this.validator, // Add this line
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          cursorColor: MyColors.iconGrey(),
          textAlign: TextAlign.start,
          controller: textformController,
          decoration: InputDecoration(
            filled: true,
            fillColor: fillColors,
            hintText: hintText,
            errorText: errorText,
            suffixIconColor: iconSuffixColor,
            suffixIcon: icon,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
          ),
          validator: validator, // Add this line
        ),
      ],
    );
  }
}
