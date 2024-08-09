import 'package:flutter/material.dart';
import 'package:trad/Utility/text_opensans.dart';
import 'package:trad/Utility/warna.dart';

class CostumeTextFormField extends StatelessWidget {
  final TextEditingController textformController;
  final Widget icon;
  final String? errorText;
  final Color fillColors;
  final Color iconSuffixColor;
  final String? hintText;
  const CostumeTextFormField({
    super.key,
    required this.textformController,
    required this.icon,
    this.errorText,
    this.hintText,
    required this.fillColors,
    required this.iconSuffixColor,
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
          decoration: InputDecoration(
            filled: true,
            fillColor: fillColors,
            hintText: hintText,
            errorText: errorText,
            suffixIconColor: iconSuffixColor,
            prefixIcon: SizedBox(
              width: 50,
              height: 32,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  icon,
                  Container(
                    width: 1,
                    color: MyColors.iconGrey(),
                  )
                ],
              ),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
          ),
        ),
      ],
    );
  }
}
