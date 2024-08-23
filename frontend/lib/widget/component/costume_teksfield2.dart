import 'package:flutter/material.dart';
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
            errorText: errorText, // Display error text below the input field
            suffixIcon: errorText != null
                ? Icon(
                    Icons.cancel, // The red cross icon
                    color: Colors.red,
                  )
                : icon, // Display the provided icon if no error
            suffixIconColor: iconSuffixColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
          ),
        ),
      ],
    );
  }
}
