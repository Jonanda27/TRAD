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
  final bool isPasswordField; // Added parameter

  const CostumeTextFormField({
    super.key,
    required this.textformController,
    required this.icon,
    this.errorText,
    this.hintText,
    required this.fillColors,
    required this.iconSuffixColor,
    this.suffixIcon,
    this.isPasswordField = false, // Default to false if not a password field
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
          obscureText: widget.isPasswordField ? _obscureText : false, // Toggle password visibility only if it's a password field
          decoration: InputDecoration(
            filled: true,
            fillColor: widget.fillColors,
            hintText: widget.hintText,
            errorText: widget.errorText,
            suffixIcon: widget.isPasswordField
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.suffixIcon != null)
                        Icon(widget.suffixIcon, color: Colors.red),
                      IconButton(
                        icon: Icon(
                          _obscureText ? Icons.visibility_off : Icons.visibility,
                          color: widget.iconSuffixColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText; // Toggle password visibility
                          });
                        },
                      ),
                    ],
                  )
                : null, // No suffix icon if not a password field
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
