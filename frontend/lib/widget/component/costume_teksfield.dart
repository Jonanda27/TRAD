import 'package:flutter/material.dart';
import 'package:trad/Utility/text_opensans.dart';
import 'package:trad/Utility/warna.dart';

class CostumeTextFormField extends StatefulWidget {
  final TextEditingController textformController;
  final Widget icon;
  final String? errorText;
  final Color fillColors;
  final Color iconSuffixColor;
  final String? hintText;
  final IconData? suffixIcon;
  final bool isPasswordField;
  final bool alwaysShowSuffix;

  const CostumeTextFormField({
    super.key,
    required this.textformController,
    required this.icon,
    this.errorText,
    this.hintText,
    required this.fillColors,
    required this.iconSuffixColor,
    this.suffixIcon,
    this.isPasswordField = false,
    this.alwaysShowSuffix = false,
  });

  @override
  _CostumeTextFormFieldState createState() => _CostumeTextFormFieldState();
}

class _CostumeTextFormFieldState extends State<CostumeTextFormField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          cursorColor: MyColors.iconGrey(),
          textAlign: TextAlign.start,
          controller: widget.textformController,
          obscureText: widget.isPasswordField ? _obscureText : false,
          decoration: InputDecoration(
            filled: true,
            fillColor: widget.fillColors,
            hintText: widget.hintText,
            errorText: widget.errorText,
            suffixIcon: (widget.isPasswordField || (widget.alwaysShowSuffix && widget.errorText != null))
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.alwaysShowSuffix && widget.errorText != null)
                        Icon(Icons.cancel, color: Colors.red),
                      if (widget.isPasswordField)
                        IconButton(
                          icon: Icon(
                            _obscureText ? Icons.visibility_off : Icons.visibility,
                            color: widget.iconSuffixColor,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                    ],
                  )
                : null,
            prefixIcon: SizedBox(
              width: 50,
              height: 32,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  widget.icon,
                  Container(
                    width: 1,
                    color: MyColors.iconGrey(),
                  ),
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