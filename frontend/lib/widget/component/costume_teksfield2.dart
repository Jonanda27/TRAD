import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trad/Utility/warna.dart';

class CostumeTextFormFieldWithoutBorderPrefix extends StatelessWidget {
  final TextEditingController textformController;
  final Widget icon;
  final String? errorText;
  final Color fillColors;
  final Color? iconSuffixColor;
  final String? hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const CostumeTextFormFieldWithoutBorderPrefix({
    super.key,
    required this.textformController,
    required this.icon,
    this.errorText,
    this.hintText,
    required this.fillColors,
    this.iconSuffixColor,
    required this.obscureText,
    this.keyboardType,
    this.inputFormatters,
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
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            filled: true,
            fillColor: fillColors,
            hintText: hintText,
            errorText: errorText,
            suffixIcon: errorText != null
                ? Icon(
                    Icons.cancel,
                    color: Colors.red,
                  )
                : icon,
            suffixIconColor: iconSuffixColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
          ),
        ),
      ],
    );
  }
}